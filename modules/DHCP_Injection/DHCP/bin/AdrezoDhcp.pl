#!/usr/bin/perl

# Copyright 2018 POSTEC Yann
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use NetAddr::IP;
use Net::IP;
use DBI;

my $BIN_MV = '/bin/mv -f';
my $BIN_RM = '/bin/rm -f';
my $madate = `date +%d/%m/%Y`;
chomp($madate);
my $TMPDIR;
my $FIC_EXCLU;
my $FIC_CONF;
my $FIC_LEASE;
my @exclu;
my %subnets;
my %infos;
my %resa;
my %lease;
my %conf;
my $baseh;

# set debug to 1 to display verbose logs in console
my $debug = 0;

# DHCP Servers list
# must match the directory created in $TMPROOT
my %servers = (
	'server1' => 'FR',
	'server2' => 'US'
);

my $ROOTDIR = '/DHCP';
my $BINDIR = $ROOTDIR . '/bin';
my $LOGDIR = $ROOTDIR . '/log';
my $DATADIR = $ROOTDIR . '/data';
my $TMPROOT = $ROOTDIR . '/tmp/';
my $TMPSQL = $TMPROOT . 'sql/';
my $FIC_LOG = $LOGDIR . '/AdrezoDhcp.log';
my $FIC_DHCPCONF = $DATADIR . '/DhcpConf';
my $FIC_SQL_RESA = $TMPSQL . '/dhcp_resa.sql';
my $FIC_SQL_LEASE = $TMPSQL . '/dhcp_lease.sql';
my $FIC_SQL_UPDATE = $DATADIR . '/dhcp_all.sql';

# set pgsql to 1 if PostgreSQL database
my $pgsql = 0;

my $sqlnet_str = '<DBI Connection String>';
my $db_user = '<Database username>';
my $db_pwd = '<Database password>';

# printLog(@)
# @text : text to display in logs
# write in LOG handle text entered as parameter
sub printLog
{
   my ($text) = @_;

   open(LOG,">>$FIC_LOG") or die "Can't open file $FIC_LOG : $!\n";
   print LOG localtime(time) . " " . $text . "\n";
   close(LOG) or die "Can't close file $FIC_LOG : $!\n";
}

# compareip($$)
# Compare two ips
# ip_1, ip_2 : in 2 ips standard format
# result : negative if ip_1 < ip_2, 0 if equal, positive if >
sub compareip($$) {
	my $ip_1 = shift;
	my $ip_2 = shift;
	
	if ($ip_1 eq $ip_2) { return 0; }
	else {
		my @iptab_1 = split(/\./,$ip_1);
		my @iptab_2 = split(/\./,$ip_2);
		if ($iptab_1[0] == $iptab_2[0]) {
			if ($iptab_1[1] == $iptab_2[1]) {
				if ($iptab_1[2] == $iptab_2[2]) {
					 return $iptab_1[3]-$iptab_2[3];
				} else { return $iptab_1[2]-$iptab_2[2]; }
			} else { return $iptab_1[1]-$iptab_2[1]; }
		} else { return $iptab_1[0]-$iptab_2[0]; }
	}
}

# ipsort(@)
# sort ip range array
sub ipsort {
	my @ipranges = @_;
	
	if (scalar(@ipranges) > 1) {
		for(my $i=0;$i<scalar(@ipranges)-1;$i++) {
			my ($s_1,$e_1) = split(/,/,$ipranges[$i]);
			my ($s_2,$e_2) = split(/,/,$ipranges[$i+1]);
			if (compareip($s_1,$s_2) > 0) {
				my $temo = $ipranges[$i+1];
				$ipranges[$i+1] = $ipranges[$i];
				$ipranges[$i] = $temo;
			}
		}
		my $last = pop(@ipranges);
		my @temp_array = ipsort(@ipranges);
		push(@temp_array,$last);
		return @temp_array;
	} else { return @ipranges;}
}

# nb2($)
# Prefix 0 if needed
sub nb2($) {
	my $nb = shift;

	if ($nb < 10) { return '0'.$nb; } else { return $nb; }
}

# convert_date($$$$$$$)
# Date Conversion US to FR
sub convert_date($$$$$$$) {
	my $month = shift;
	my $day = shift;
	my $year = shift;
	my $hour = shift;
	my $min = shift;
	my $sec = shift;
	my $pm = shift;

	if ($pm eq 'PM') { $hour+=12; }
	$hour = nb2($hour);
	if ($hour == 24) { $hour = '00'; }

	return $day . '/' . $month . '/' . $year . ' ' . $hour . ':' . $min . ':' . $sec;
}

# ReadExclu()
# read exclusions file
# contains scopes which configuration will not be taken into account
sub ReadExclu() {
	open(EX,"$FIC_EXCLU") or die "Can't open file $FIC_EXCLU : $!\n";
	while (<EX>) {
		my $line = $_;

		if (substr($line,0,1) ne '#') {
			printLog("Exclusion File : Exclusion of " . $line);
			push(@exclu,$line);
		}
	}
	close(EX);
}

sub LightConf($) {
	my $lang = shift;

	my $lang_fr = 0;
	my $lang_us = 0;
	if ($lang eq 'FR') { $lang_fr = 1; }
	if ($lang eq 'US') { $lang_us = 1; }

	open(RES,">>$FIC_DHCPCONF") or die "Can't open file $FIC_DHCPCONF : $!\n";
	open(DB,"$FIC_CONF") or die "Can't open file $FIC_CONF : $!\n";
	open(LEA,">$FIC_LEASE") or die "Can't open file $FIC_LEASE : $!\n"; 

	my $serveur;
	my %exclude;
	# Analyze DHCP configuration
	while(<DB>) {
		my $line = $_;
		$line =~ s/\r//g;
		
		# Retrieve server IP
		if ($lang_fr && $line =~ /Informations de configuration pour le serveur (\S+)/) { $serveur = $1; }
		if ($lang_us && $line =~ /Configuration Information for Server (\S+)/) { $serveur = $1; }
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) set state (\d)/) {
			# Exclude inactive scopes
			if ($2 == 0 && !grep(/$1/,@exclu)) {
				printLog("Add Exclusion of $1");
				push(@exclu,$1);
			}
			# Analyze not excluded active scopes
			if ($2 == 1 && !grep(/$1/,@exclu)) {
				my $scope = $1;
				open(SCOPE,"$TMPDIR/$scope.txt") or die "Can't open file $TMPDIR/$scope.txt : $!\n";
				printLog("Analyze Scope " . $scope . " : ");
				my $cptScope = 0;
				while(<SCOPE>) {
					my $l_scope = $_;
					my $scope_found = 0;
					my $ip;
					my $mac;
					my $leas;
					my $name = '';
					if ($lang_fr && $l_scope =~ /^([\d\.]+)\s*-\s*[\d\.]+\s*-\s*(\w{2}-\w{2}-\w{2}-\w{2}-\w{2}-\w{2})\s*-\s*(\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}:\d{2})\s*-\w-\s*(\S*)/) {
						$ip = $1;
						$mac = $2;
						$leas = $3;
						$name = $4;
						$scope_found = 1;
					}
					if ($lang_us && $l_scope =~ /^([\d\.]+)\s*-\s*[\d\.]+\s*-\s*(\w{2}-\w{2}-\w{2}-\w{2}-\w{2}-\w{2})\s*-\s*(\d{1,2}\/\d{2}\/\d{4} \d{1,2}:\d{2}:\d{2} [AP]M)\s*-\w-\s*(\S*)/) {
						$ip = $1;
						$mac = $2;
						$leas = $3;
						$name = $4;
						$scope_found = 1;
						if ($leas =~ /(\d{1,2})\/(\d{2})\/(\d{4}) (\d{1,2}):(\d{2}):(\d{2}) ([AP]M)/) {
							$leas = convert_date($1,$2,$3,$4,$5,$6,$7);
						}
					}
					if ($scope_found) {
						$mac =~ s/-//g;
						$cptScope++;
						# Only host part are keeped
						my $firstpoint = index($name,'.');
						if ($firstpoint != -1) {
							$name = substr($name,0,$firstpoint);
						}
						# Reduce name to 20 characters
						$name = substr($name,0,20);
						# Write lease informations
						print LEA "Dhcp Server " . $serveur . " Scope " . $scope . " Add Lease IP " . $ip . " MAC " . $mac . " Lease " . $leas . " Name " . $name . "\n";
					}
				}
				printLog($cptScope . " Lease processed");
				close(SCOPE) or die "Can't close file $TMPDIR/$scope.txt : $!\n";
			}
		}
		
		# Rewrite useful configuration lines
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) Add iprange ([\d\.]+) ([\d\.]+)/ ||
			$line =~ /Dhcp Server.+Scope ([\d\.]+) Add reservedip ([\d\.]+) ([a-f\d]+) "(.+)"/) {
			if (!grep(/$1/,@exclu)) {	print RES $line; }
		}
		# Save excluderange to sort later
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) add excluderange ([\d\.]+) ([\d\.]+)/) {
			my @myrange = ($2.','.$3);
			if (exists $exclude{$1}) {
				push(@{$exclude{$1}},$myrange[0]);
			} else { $exclude{$1} = \@myrange; }
		}
	}
	# Write sorted excluderange
	foreach my $sub (keys %exclude) {
		@{$exclude{$sub}} = ipsort(@{$exclude{$sub}});
		foreach my $range (@{$exclude{$sub}}) {
			my ($start,$end) = split(/,/,$range);
			print RES "Dhcp Server " . $serveur . " Scope " . $sub . " add excluderange " . $start . " " . $end . "\n";
		}
	}

	# Close files
	close(LEA) or die "Can't close file $FIC_LEASE : $!\n";
	close(DB) or die "Can't close file $FIC_CONF : $!\n";
	close(RES) or die "Can't close file $FIC_DHCPCONF : $!\n";
}

# MergeFiles()
# Merge files configuration dump + dhcp lease informations
sub MergeFiles() {
	open(RES,">>$FIC_DHCPCONF") or die "Can't open file $FIC_DHCPCONF for merge : $!\n";
	open(LEA,"$FIC_LEASE") or die "Can't open file $FIC_LEASE for merge : $!n";
	while(<LEA>) { print RES $_; }
	close(LEA) or die "Can't close file $FIC_LEASE after merge : $!\n";
	close(RES) or die "Can't close file $FIC_DHCPCONF after merge : $!\n";
	printLog("Merge conf and lease processed");	
}

# PurgeTmpServer()
# Clean temporary files
sub PurgeTmpServer() {
	if (system("$BIN_RM $TMPDIR/*")) { printLog("***Error Clean Temporary Files"); }
	else { printLog("Clean temporary files OK"); }
}

# full($)
# in : ip part (number)
# out : full ip part with 0 on 3 char (string)
sub full($) {
	my $nb = shift;
	if ($nb < 10) { return "00" . $nb; }
	elsif ($nb < 100) { return "0" . $nb; }
	else { return $nb; }
}

# convert_ip($)
# in : @ip std format
# out : @ip database format
sub convert_ip($) {
	my $ip = shift;
	my @iptab = split(/\./,$ip);
	return full($iptab[0]) . full($iptab[1]) . full($iptab[2]) . full($iptab[3]);
}

# analyse()
# parsing DHCP server configuration file $FIC_DHCPCONF
# Create all informations hashes on scopes
sub analyse() {
	my $sth;
	printLog("Connect to database");
	$baseh=DBI->connect("DBI:$sqlnet_str",$db_user,$db_pwd) or die 'Unable to connect to database ' . $sqlnet_str . ": $DBI::errstr\n";
	
	open(REZA,">$FIC_SQL_RESA") or die "Can't open file $FIC_SQL_RESA : $!\n";
	open(LEA,">$FIC_SQL_LEASE") or die "Can't open file $FIC_SQL_LEASE : $!\n";
	open(DB,"$FIC_DHCPCONF") or die "Can't open file $FIC_DHCPCONF : $!\n";
	while(<DB>) {
		my $line = $_;

		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) Add iprange ([\d\.]+) ([\d\.]+)/) {
			my $subnet = $1;
			my @myrange = ($2.",".$3);
			my @myips;
			my $s_id;
			my $s_mask;
			my $s_ctx;
			my $s_site;
			$subnets{$subnet} = \@myrange;
			$conf{$subnet} = \@myips;
			my $sql_subnet = "SELECT id,mask,ctx,site FROM subnets WHERE IP = '".convert_ip($subnet)."'";
			$sth = $baseh->prepare($sql_subnet) or die "Unable to prepare statement $sql_subnet" . $baseh->errstr;
			$sth->execute() or die "Unable to execute query $sql_subnet" . $sth->errstr;
			$sth->bind_columns( \$s_id, \$s_mask, \$s_ctx, \$s_site);
			while ($sth->fetch() ) {
				printLog("SQL : $sql_subnet => $s_id,$s_mask,$s_ctx,$s_site");
				$infos{$subnet} = {
					id		=> $s_id,
					mask	=> $s_mask,
					ctx	=> $s_ctx,
					site	=> $s_site,
				};
			}
			$sth->finish();
		}
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) add excluderange ([\d\.]+) ([\d\.]+)/) {
			my $subnet = $1;
			my $exclude_start = $2;
			my $exclude_end  = $3;
			if (exists $subnets{$subnet}) {
				printLog("Exclusion on $subnet : $exclude_start,$exclude_end");
				push(@{$subnets{$subnet}},$exclude_start.",".$exclude_end);
			} else { printLog("Exclusion Range on scope $subnet dont exist"); }
		}
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) Add reservedip ([\d\.]+) ([a-f\d]+) "(.+)" ".*" ".*"/) {
			my $subnet = $1;
			my $ip = $2;
			my $mac = $3;
			my $name = $4;
			my $firstpoint = index($name,'.');
			if ($firstpoint != -1) { $name = substr($name,0,$firstpoint); }
			if (length($name) > 20) { $name = substr($name,0,20); }
			if (exists $subnets{$subnet}) {
				my $ipc = convert_ip($ip);
				if (exists $resa{$subnet}) {
					push(@{$resa{$subnet}},$ipc);
				} else {
					my @myresa = ($ipc);
					$resa{$subnet} = \@myresa;
				}
				### Avoid double information when 2 DHCP servers have same scope
				if (scalar(grep(/$ipc/,@{$resa{$subnet}}))==1) {
					if ($pgsql) {
						print REZA "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$subnet}{ctx} . "," . $infos{$subnet}{site} . ",'" . $name . "','DHCP Static Reservation','" . $ipc . "'," . $infos{$subnet}{mask} . ",'" . $mac . "'," . $infos{$subnet}{id} . ",'dhcp','dhcp',to_timestamp('" . $madate . "','DD/MM/YYYY'))\n";
					} else {
						print REZA "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$subnet}{ctx} . "," . $infos{$subnet}{site} . ",'" . $name . "','DHCP Static Reservation','" . $ipc . "'," . $infos{$subnet}{mask} . ",'" . $mac . "'," . $infos{$subnet}{id} . ",'dhcp','dhcp','" . $madate . "')\n";
					}
				}
			} else { printLog("Reservation $ip on scope $subnet dont exist"); }
		}
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) Add Lease IP (.+) MAC (.+) Lease (.+) Name (.*)/) {
			my $subnet = $1;
			my $ip = $2;
			my $mac = $3;
			my $leas = $4;
			my $name = $5;
			$name = uc($name);
			if (length($name) == 0) { $name = 'Unknown'; }
			
			if (exists $subnets{$subnet}) {
				my $ipc = convert_ip($ip);
				if (exists $lease{$subnet}) {
					push(@{$lease{$subnet}},$ipc);
				} else {
					my @mylease = ($ipc);
					$lease{$subnet} = \@mylease;
				}
				if ($pgsql) {
					print LEA "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,TEMP,DATE_TEMP,USR_TEMP,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$subnet}{ctx} . "," . $infos{$subnet}{site} . ",'" . $name . "','DHCP Address','" . $ipc . "'," . $infos{$subnet}{mask} . ",'" . $mac . "'," . $infos{$subnet}{id} . ",1,to_timestamp('" . $leas  . "','DD/MM/YYYY HH24:MI:SS'),'dhcp','dhcp','dhcp',to_timestamp('" . $madate . "','DD/MM/YYYY'))\n";
				} else {
					print LEA "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,TEMP,DATE_TEMP,USR_TEMP,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$subnet}{ctx} . "," . $infos{$subnet}{site} . ",'" . $name . "','DHCP Address','" . $ipc . "'," . $infos{$subnet}{mask} . ",'" . $mac . "'," . $infos{$subnet}{id} . ",1,to_date('" . $leas  . "','DD/MM/YYYY HH24:MI:SS'),'dhcp','dhcp','dhcp','" . $madate . "')\n";
				}
			} else { printLog("Lease $ip on scope $subnet dont exist"); }
		}
	}
	close(DB);
	close(REZA);
	close(LEA);
	printLog("Close database connection");
	$baseh->disconnect;
}

# create_subnet($$$)
# in : scope, active range, excluderange to process
# Create IP array for given scope
sub create_subnet($$$) {
	my $subnet = shift;
	my $range = shift;
	my $exclude = shift;
	my ($s_start,$s_end) = split(/,/,$range);

	printLog("Create Scope $subnet with range $s_start to $s_end");
	if (scalar(@$exclude) == 0) {
		printLog("Scope $subnet, No more excluderange. Create final IP array");
		my $iprange = new Net::IP ($s_start.' - '.$s_end);
		do {
			push(@{$conf{$subnet}},convert_ip($iprange->ip()));
			if ($debug) { print $iprange->ip().", "; }
		} while (++$iprange)		
	} else {
		my $ex_range = shift(@$exclude);
		my ($ex_start, $ex_end) = split(/,/,$ex_range);
		printLog("Scope $subnet, Process Exclusions $ex_start to $ex_end");
		$ex_start = NetAddr::IP->new($ex_start.'/8') - 1;
		$ex_end = NetAddr::IP->new($ex_end.'/8') + 1;
		printLog("Exclusions limits ".$ex_start->addr()." to ".$ex_end->addr());
		my $ips_s = new Net::IP ($s_start);
		my $ips_e = new Net::IP ($s_end);
		my $ipe_s = new Net::IP ($ex_start->addr());
		my $ipe_e = new Net::IP ($ex_end->addr());
		if ($ipe_s->bincomp('ge',$ips_s)) {
			printLog("Create IP of $subnet. Range " . $ips_s->ip() . ' to ' . $ipe_s->ip());
			my $iprange = new Net::IP ($ips_s->ip().' - '.$ipe_s->ip());
			do {
				push(@{$conf{$subnet}},convert_ip($iprange->ip()));
				if ($debug) { print $iprange->ip().", "; }
			} while (++$iprange)
		}
		if ($ipe_e->bincomp('le',$ips_e)) {
			printLog("Return Function Create for scope $subnet. Range " . $ipe_e->ip() . " to " . $ips_e->ip());
			create_subnet($subnet,$ipe_e->ip().",".$ips_e->ip(),$exclude);
		}
	}
}

# del_ip($)
# Delete static IP and leases for given scope
sub del_ip($) {
	my $subnet = shift;
	my $cpt = 0;
	
	# Delete static reservations
	foreach my $static (@{$resa{$subnet}}) {
		my $i = 0;
		my $bNotFound = 1;
		while ($bNotFound && $i < scalar(@{$conf{$subnet}})) {
			if (${$conf{$subnet}}[$i] eq $static) {
				splice(@{$conf{$subnet}},$i,1);
				$bNotFound = 0;
			}
			$i++;
		}
		$cpt++;
	}
	printLog("Scope $subnet. Delete $cpt static reservations");

	$cpt = 0;
	# Delete leases
	foreach my $static (@{$lease{$subnet}}) {
		my $i = 0;
		my $bNotFound = 1;
		while ($bNotFound && $i < scalar(@{$conf{$subnet}})) {
			if (${$conf{$subnet}}[$i] eq $static) {
				splice(@{$conf{$subnet}},$i,1);
				$bNotFound = 0;
			}
			$i++;
		}
		$cpt++;
	}
	printLog("Scope $subnet. Delete $cpt leases");
}

# updateDB($)
# Process SQL file
# in : SQL file path
sub updateDB($) {
	my $FIC_SQL = shift;
	my $sth;
	my $cpt = 0;
	my $cptError = 0;
	
	printLog("Connection to database to process $FIC_SQL");
	if ($pgsql) {
		$baseh=DBI->connect("DBI:$sqlnet_str",$db_user,$db_pwd,{AutoCommit => 1, PrintError => 1, RaiseError => 0, ShowErrorStatement => 1}) or die 'Unable to connect to database ' . $sqlnet_str . ": $DBI::errstr\n";
	} else {
		$baseh=DBI->connect("DBI:$sqlnet_str",$db_user,$db_pwd) or die 'Unable to connect to database ' . $sqlnet_str . ": $DBI::errstr\n";
	}
	open(SQL,"$FIC_SQL") or die "Can't open file $FIC_SQL : $!\n";
	
	while(<SQL>) {
		my $sql = $_;
		chomp($sql);
		$sth = $baseh->prepare($sql) or die "Unable to prepare statement $sql" . $baseh->errstr;
		if (!$sth->execute()) {
			printLog("Unable to execute query $sql" . $sth->errstr);
			$cptError++;
		}
		$cpt++;
	}
	$sth->finish;
	printLog('Process ' . $cpt . ' SQL request. ' . $cptError . ' errors.');
	close(SQL) or die "Can't close file $FIC_SQL : $!\n";
	$baseh->disconnect;
	printLog("Close database connection");
	return $cptError;
}

# PurgeTmpSQL()
# Clean SQL temporary files
sub PurgeTmpSQL() {
	if (system("$BIN_RM $TMPSQL/*")) { printLog("***Error cleaning SQL temporary files"); }
	else { printLog("Cleaning SQL temporary files OK"); }
}

# PurgeTmpData()
# Clean result files
sub PurgeTmpData() {
	if (system("$BIN_RM $DATADIR/*")) { printLog("***Error cleaning resutl files"); }
	else { printLog("Cleaning Result files OK"); }
}

# Main Function
sub ParseDhcpConf() {
	printLog("Start Analyze");
	analyse();
	printLog("End Analyze");
	
	# Open result file
	open(RES,">$FIC_SQL_UPDATE") or die "Can't open file $FIC_SQL_UPDATE : $!\n";
	# Delete all DHCP records
	if ($pgsql<1) {
		print RES "alter session set nls_date_format='DD/MM/YYYY'\n";
	}
	print RES "DELETE FROM ADRESSES WHERE TYPE='dhcp'\n";
	
	# Loop on scopes
	foreach my $key (keys %subnets) {
		# Create @IP of subnet with global range and sorted excluderange
		my $global_range = shift(@{$subnets{$key}});
		create_subnet($key,$global_range,@{subnets{$key}});
		# Delete already defined @IP (static or lease)
		del_ip($key);

		my ($mask, $rezo) = split(/;/,$infos{$key});
		printLog("Scope $key, Final Dynamic IP = ".scalar(@{$conf{$key}}));
		# Write SQL insert for each @IP
		foreach my $subn (@{$conf{$key}}) {
			if ($pgsql) {
				print RES "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,SUBNET,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$key}{ctx} . "," . $infos{$key}{site} . ",'RESA_DHCP','DHCP Reservation','" . $subn. "'," . $infos{$key}{mask} . "," . $infos{$key}{id} . ",'dhcp','dhcp',to_timestamp('" . $madate . "','DD/MM/YYYY'))\n";
			} else {
				print RES "INSERT INTO ADRESSES (ID,CTX,SITE,NAME,DEF,IP,MASK,SUBNET,TYPE,USR_MODIF,DATE_MODIF) VALUES(0," . $infos{$key}{ctx} . "," . $infos{$key}{site} . ",'RESA_DHCP','DHCP Reservation','" . $subn. "'," . $infos{$key}{mask} . "," . $infos{$key}{id} . ",'dhcp','dhcp','" . $madate . "')\n";
			}
		}
	}
	
	# Add static informations
	open(REZA,"$FIC_SQL_RESA") or die "Can't open file $FIC_SQL_RESA : $!\n";
	while(<REZA>) { print RES $_;	}
	close(REZA) or die "Can't close file $FIC_SQL_RESA : $!\n";
	printLog("Add static reservations informations OK");
	
	# Add lease informations
	open(LEA,"$FIC_SQL_LEASE") or die "Can't open file $FIC_SQL_LEASE : $!\n";
	while(<LEA>) { print RES $_; }
	close(LEA) or die "Can't close file $FIC_SQL_LEASE : $!\n";
	printLog("Add lease informations OK");
	
	# Add final commit
	if ($pgsql<1) {
		print RES "commit";
	}
	
	# Close result file
	close(RES) or die "Can't close file $FIC_SQL_UPDATE : $!\n";
	
	# Update database
	my $ErrorDB = updateDB($FIC_SQL_UPDATE);

	# Clean temporary files
	PurgeTmpSQL();
	if ($ErrorDB == 0) { PurgeTmpData(); }
}

# Main Loop
sub main() {
	PurgeTmpData();
	foreach my $server (keys %servers) {
		$TMPDIR = $TMPROOT . $server;
		$FIC_EXCLU = $TMPDIR . '/exclusions';
		$FIC_CONF = $TMPDIR . '/conf.txt';
		$FIC_LEASE = $TMPDIR . '/dhcp_lease';
		printLog('Processing ' . $server);
		ReadExclu();
		LightConf($servers{$server});
		MergeFiles();
		PurgeTmpServer();
	}
	ParseDhcpConf();
}

main();
