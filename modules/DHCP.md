Retrieving DHCP informations from your DHCP servers are not fully integrated in this application at the moment.  
A solution is on the application roadmap.

An external module allows you to collect DHCP leases from Microsoft DHCP Servers and inject them into adrezo database.  
This solution is old, limited, use perl scripts and unsecure ftp to transfer informations.

One script on dhcp servers collect dhcp database through `netsh dhcp` calls and send it to a server via FTP which analyze and build sql injection into adrezo database.  

# Windows DHCP Server 
Tested on Windows Server 2008 to 2012 (US and French Language) with Perl 5 support (ActivePerl)  
Only Microsoft Windows DHCP servers are supported.

Copy the `DHCP_Server/adrezo_dhcp` directory onto the dhcp server.

Install a Perl environnement like ActivePerl.

Change the informations in `bin/ftp_cmd.txt` :
- `<Inject Server>` : IP or hostname of the FTP server
- `<FTP login>` : login of the FTP server
- `<FTP password>` : password of the FTP Server
- `<adrezo_dhcp path>` represents the path where you copy the adrezo_dhcp directory, example `c:\adrezo_dhcp`
- `<Server>` : the hostname of this server, must match the information given in the injection script

If you don't want to process some scopes, put them in `data/exclusions`.

Change in `bin/ExportDhcpConf.pl` the parameter `$ROOTDIR` to the correct location of adrezo_dhcp directory.

Create a scheduled task or launch manually the script `bin\ExportDhcpConf.pl` under user with authorization to execute netsh dhcp calls.  
Example : every day at 9 pm

# Analyze Server
__This script has not yet been tested with PostgreSQL database, only Oracle database__  
Tested with linux server with perl environnement installed.
The perl script use those modules :
- NetAddr::IP
- Net::IP
- DBI  

Copy the `DHCP_Injection/DHCP` directory onto this server.

In `bin/AdrezoDhcp.pl` :
- Check the parameter `$ROOTDIR` point to the correct location of DHCP directory
- Check the parameters `$BIN_MV` and `$BIN_RM` point to the correct location of the mv and rm binaries
- Change the `$pgsql` to 1 if you're using a PostgreSQL database 
- Change the parameters `$sqlnet_str`, `$db_user` and `$db_pwd` with the connection informations to adrezo database using DBI specifications
- Modify the DHCP servers list `%servers`, the key is the server name, the value is the OS language (netsh is language dependent), only FR or US are supported

If you don't want to process some scopes, put them in `tmp/exclusions`.

Install and configure a FTP Server with root on `tmp` directory  
Inside this directory, for each server, create a directory named with the server name

Schedule this script after the windows dhcp server script schedule time  
Example : every day at 10pm
