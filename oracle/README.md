# Oracle Database Server

If you have an oracle database instead of PostgreSQL database, follow the instructions below

## Change JDBC oracle drivers
Put file `ojdbc7.jar` (Oracle 12 jdbc driver) into `WEB-INF/lib`  
You can remove the PostgreSQL JDBC driver : `jdbc-postgresql.jar`

## Prepare database connection

1. Create a Oracle database with AL32UTF8 encoding and an account to access it  

2. Change the context.xml file in META-INF directory with the one here

````
<?xml version="1.0" encoding="UTF-8"?>
<Context docBase="${catalina.base}/webapps/adrezo" swallowOutput="true">
<Resource name="jdbc/adrezo" auth="Container" type="javax.sql.DataSource" driverClassName="oracle.jdbc.OracleDriver" url="jdbc:oracle:thin:@<db_host>:<db_port>:<db_name>" username="<db_user>" password="<db_pwd>" maxTotal="20" maxIdle="10" maxWaitMillis="-1" />
</Context>
````
Replace with your own parameters :
- &lt;db_host&gt; : hostname of Oracle server
- &lt;db_port&gt; : port of Oracle instance
- &lt;db_name&gt; : database name
- &lt;db_user&gt; : user account to access the database
- &lt;db_pwd&gt; : user password

The last three parameters (pool connections) can be changed as well to suits your needs.

You could also put your tnsname connection string  instead of `<db_host>:<db_port>:<db_name>`  
like that `(DESCRIPTION=(LOAD_BALANCE=on)(FAILOVER=on)(ADRESS=(PROTOCOL=TCP)(HOST=<db_host>)(PORT=<db_port>))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=<db_name>)(FAILOVER_MODE=(TYPE=SELECT)(METHOD=BASIC)(RETRIES=5)(DELAY=1))))`

If you need to change the jdbc/adrezo name, you must change it as well in `WEB-INF/web.xml` see Install section

## Change web.xml parameters

Change the value of _env-entry_ __db_type__ from postgresql to oracle :

````
<env-entry>
	<description>DB Type : oracle,postgresql</description>
	<env-entry-name>db_type</env-entry-name>
	<env-entry-type>java.lang.String</env-entry-type>
	<env-entry-value>oracle</env-entry-value>
</env-entry>
````

## Continue installation
Continue installation with customizations as defined in [Install section](../INSTALL.md)
