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

# Environment

The application has been tested on :
- Applications Servers
  - Tomcat 7.0, 8.5, 9.0
  - Weblogic 12.2.1
- Database Servers
  - PostgreSQL 9.4, 10.3
  - Oracle 12.1

and with browsers :
- Vivaldi
- Opera
- Mozilla Firefox
- Google Chrome
- Internet Explorer 11

# Installation

See [Install section](./INSTALL.md)

# First start

Check inline application help by clicking on ![Help Icon](./icon_help.png) in the top menu bar

# Modules

Some modules required configuration :
- [NAS](./modules/NAS.md)
- [Photos](./modules/photos.md)
- [Mail](./modules/mail.md)
- [DHCP](./modules/DHCP.md)

# License

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

## Used libraries Licenses
All licenses for java libraries, javascript libraries and image collections are in [licenses directory](./licenses/README.md)
