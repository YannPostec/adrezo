# Adrezo
Adrezo is a light IPv4 Address Management software written in JSP.  
It allows you to maintain IP Address database organised in subnets within sites.  
It comes with various modules to also :
- manage photo collections of your IT rooms
- manage your supply of network & cabling furnitures on each site
- display availability statistics from your network infrastructure taken from Cacti application if used

Some features available are :
- Local and LDAP Authentication/Authorization
- CSV Import/Export of some application data
- REST API to access and manage most of the application data

## Environment

The application has been tested on :
- Applications Servers
  - Tomcat 9.0, 8.5, 7.0
  - Weblogic 12.2.1
- Database Servers
  - PostgreSQL 13.5, 11.4, 10.3, 9.4
  - Oracle 12.1

and with browsers :
- Vivaldi
- Opera
- Mozilla Firefox
- Google Chrome
- Internet Explorer 11

## Installation

See [Install section](./INSTALL.md)  
Take the last release from [Releases](../../releases)  
or see below for Beta versions

### Installation of Beta Version
If you clone this repository for upgrade, you will have all current developments (Beta) since the last release and you must modify the database if needed.
To do that check for the last ./update/sqlupdate_xxx.jsp file and inject the sql lines you will find inside that file, except the last one which changes the database version.
After that when upgrading from release, you must rollback those instructions for the upgrade process to perform without errors.

## Upgrade

Prepare the new adrezo directory with an upgraded version.

You must copy or modify some files from the actual version :
- log/ directory or let the application start new ones
- pictures/ directory if you store pictures locally
- WEB-INF/web.xml if needed
- WEB-INF/classes/adrezo.properties if needed
- WEB-INF/classes/log4j2.xml if needed
- WEB-INF/classes/quartz-config.xml if needed
- META-INF/context.xml

See the release notes to know if some of those files have their structure changed.  
If it is the case, you must put your configuration in those new files, otherwise you can just copy them.

Start the instance on this new directory.

If there is a difference in database version and application version, a page invites you to enter the admin password to proceed.  
After the upgrade, you are redirected to login page.

## First start

Check inline application help by clicking on ![Help Icon](./icon_help.png) in the top menu bar

## Modules

Some modules required configuration :
- [NAS](./modules/NAS.md)
- [Photos](./modules/photos.md)
- [Mail](./modules/mail.md)
- [DHCP](./modules/DHCP.md)

## License

Adrezo is released under the [Apache 2.0 license](./LICENSE).

````
Copyright 2018 POSTEC Yann

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
````

### Used libraries Licenses
All licenses for java libraries, javascript libraries and image collections are in [licenses directory](./licenses/README.md)
