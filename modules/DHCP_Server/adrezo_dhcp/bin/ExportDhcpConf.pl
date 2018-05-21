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

my $ROOTDIR = 'c:/adrezo_dhcp';
my $BINDIR = $ROOTDIR . '/bin';
my $LOGDIR = $ROOTDIR . '/log';
my $DATADIR = $ROOTDIR . '/data';
my $FIC_LOG = $LOGDIR . '/ExportDhcpConf.log';
my $LOG_FTP = $LOGDIR . '/FTP.log';
my $FIC_EXCLU = $DATADIR . '/exclusions';
my $FIC_CONF = $DATADIR . '/conf.txt';
my $FIC_CMD_FTP = $BINDIR . '/ftp_cmd.txt';

my @exclu;

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

# GenConf()
# Command which generate dhcp configuration
# Storage in temp file
sub GenConf() {
	if (system("netsh dhcp server dump > $FIC_CONF")) { printLog("***Error Dump Conf"); }
	else { printLog("Dump Conf OK"); }
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

sub LightConf() {
	open(DB,"$FIC_CONF") or die "Can't open file $FIC_CONF : $!\n";

	# Scanning DHCP configuration file
	while(<DB>) {
		my $line = $_;
		$line =~ s/\r//g;
		
		if ($line =~ /Dhcp Server.+Scope ([\d\.]+) set state (\d)/) {
			# Exclude inactive scopes
			if ($2 == 0 && !grep(/$1/,@exclu)) {
				printLog("Add Exclusion of $1");
				push(@exclu,$1);
			}
			#Analyze not excluded active scopes
			if ($2 == 1 && !grep(/$1/,@exclu)) {
				my $scope = $1;
				if (system("netsh dhcp server scope $scope show clients 1 > $DATADIR/$scope.txt")) { printLog("***Error Dump scope $scope"); }
				else { printLog("Dump $scope OK"); }
			}
		}
	}

	# Close files
	close(DB) or die "Can't close file $FIC_CONF : $!\n";
}

sub sendFTP() {
	if (system("ftp -s:$FIC_CMD_FTP > $LOG_FTP")) { printLog("***Error transmitting files with FTP"); }
	else { printLog("Files transmitted with FTP"); }
}

sub Purge() {
	my $DELDIR = $DATADIR . '/*.txt';
	$DELDIR=~s/\//\\/g;
	if (system("del /Q/F $DELDIR")) { printLog("***Error in data files cleaning"); }
	else { printLog("Clean data files OK"); }
}

# Main loop
sub main() {
	Purge();
	GenConf();
	ReadExclu();
	LightConf();
	sendFTP();
}

main();
