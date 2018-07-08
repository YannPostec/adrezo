# Adrezo Install

This section will cover installation on Tomcat with PostgreSQL database

For others installation types :
- Refer to [the weblogic section](./weblogic/) 
- Refer to [the oracle section](./oracle/)

## Install web application
Make the `adrezo` directory accessible from your tomcat webapps folder.
You can copy it to a directory of your choice, suffix it with the version and link it from the tomcat webapps folder.

## Prepare database connection

1. Create a PostgreSQL database with UTF8 encoding and an account to access it  
More on [PostgreSQL website](https://www.postgresql.org/docs/10/static/index.html)  

2. The JDBC Driver for PostgreSQL 10 is already in `WEB-INF/lib/jdbc-postgresql-10.3.jar`, you can delete it if you have your own in your instance classpath

3. The context.xml file is already in `META-INF` directory like defined in tomcat documentation `$CATALINA_BASE/webapps/[webappname]/META-INF/context.xml`
You can transfer it to `$CATALINA_BASE/conf/[enginename]/[hostname]/[webappname].xml` to follow your installation standards.

This file defines the database connection parameters
````
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="${catalina.base}/webapps/adrezo" swallowOutput="true">
<Resource name="jdbc/adrezo" auth="Container" type="javax.sql.DataSource" driverClassName="org.postgresql.Driver" url="jdbc:postgresql://<db_host>:<db_port>/<db_name>" username="<db_user>" password="<db_pwd>" maxTotal="20" maxIdle="10" maxWaitMillis="-1" />
</Context>
````
Replace with your own parameters :
- &lt;db_host&gt; : hostname of PostgreSQL server
- &lt;db_port&gt; : port of PostgreSQL instance
- &lt;db_name&gt; : database name
- &lt;db_user&gt; : user account to access the database
- &lt;db_pwd&gt; : user password

The last three parameters (pool connections) can be changed as well to suits your needs.

If you need to change the jdbc/adrezo name, you must change it as well in `WEB-INF/web.xml`, see below section

## Customize log file
All log configuration is in file `WEB-INF/classes/log4j.xml`

In all appenders configured, the file parameter contains the path to application `log` directory  
Example : `${catalina.base}/webapps/adrezo/log/adrezo-default.log`  
Change them if needed

## Customize web.xml

### Context parameters

Change the default language of the application in `javax.servlet.jsp.jstl.fmt.fallbackLocale`  
Language available :
- English : en
- Français : fr

If you change the JNDI name (jdbc/adrezo) in context.xml, you must reflect it in `javax.servlet.jsp.jstl.sql.dataSource`

### Application configuration
You can change the session timeout (in minutes) of the application in
````
<session-config>
	<session-timeout>360</session-timeout>	
</session-config>
````
If you change the JNDI name (jdbc/adrezo) in context.xml, you must reflect it in two more parameters
````
<resource-ref>
	<description>The default data source for JSTL.</description>
	<res-ref-name>jdbc/adrezo</res-ref-name>
	<res-type>javax.sql.DataSource</res-type>
	<res-auth>Container</res-auth>
</resource-ref>
	
<env-entry>
	<description>JNDI name of JDBC pool</description>
	<env-entry-name>jdbc_jndi</env-entry-name>
	<env-entry-type>java.lang.String</env-entry-type>
	<env-entry-value>jdbc/adrezo</env-entry-value>
</env-entry>
````
## JSTL Libraries
If you already have jstl libraries installed in your lib environment in Tomcat or Weblogic,  
you could delete those files in `WEB-INF/lib` :
- jstl-api-1.2.1.jar
- jstl-impl-1.2.1.jar

## Start Application
Start the application in your Application server and connect to the application URL.  

If database is configured properly, a page invites you to install the database.

Once done, you are forwarded to login page.  
Default credentials are :
- Login : __admin__
- Password : __admin__

## Optional configuration

The following configuration is not mandatory to start the application.
You could review those elements later on.

### Environment Entries in web.xml
Photos storage and access are defined in environment entries :
- photo_webhost
- photo_cifshost
- photo_dir
- photo_cifs


### Customize application properties
Some properties are located in `WEB-INF/classes/adrezo.properties`
They are optional for a first start

- mail.* define your mail server (mainly for scheduled tasks)
- ldap.maxactive define the number of connections in ldap pool if any configured
- ldap.maxidle define the number of connections to stay in idle state
- api.timeout define the number of seconds an authentication token is active on API calls
- cacti.* define the connection to your cacti database if you want to use the NAS module


