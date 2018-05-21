# Weblogic Application Server

If you have a Weblogic server instead of Tomcat server, follow the instructions below

## Install web application
Clone `adrezo` directory to your weblogic applications folder  
Something like `/oracle/wls12212/mycompany/mydomain/applications/`

## Add weblogic.xml file
Put file `weblogic.xml` into `WEB-INF/`  

## Prepare database connection

1. Delete the META-INF directory

2. Create a Data Source in Weblogic console

Put jdbc/adrezo as JNDI name, or change it as well in `WEB-INF/web.xml` see Install section

## Add java librairies

Put the following files into `WEB-INF/lib` :
- spring-web-4.3.12.RELEASE.jar
- spring-webmvc-4.3.12.RELEASE.jar
- xmlschema-core-2.2.2.jar

## Customize log file
All log applications is in file `WEB-INF/classes/log4j.xml`

In all appenders configured, the file parameter contains the path to application `log` directory  
In weblogic, you must put the full absolute path to this directory  
Example : `/oracle/wls12212/mycompany/mydomain/applications/adrezo/log/adrezo-default.log`  
Change them if needed

## Continue installation
Continue installation with customize web.xml as defined in [Install section](../INSTALL.md)
