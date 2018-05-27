NAS module allows you to collect and view Network Availability Statistics from your Cacti database  
Tested on Cacti 0.8.8h with MySQL database

# Adrezo Configuration

Modify the following properties in `WEB-INF/classes/adrezo.properties` in order to acces the Cacti database :
- cacti.host : Cacti database hostname or ip address
- cacti.port : Cacti database port, usually 3306 for mysql
- cacti.dbname : Cacti database name, usually cacti
- cacti.user : Cacti database login, usually cactiuser
- cacti.pwd : Cacti database password, usually cactiuser
- cacti.tz : Timezone for MySQL

# MySQL Configuration

If your mysql cacti database is located on another server, you must provide a user with remote accessibility to the specified database.

To create a user with remote access to cacti database  
`grant all on cacti.* to 'cactiremote'@'%' identified by 'somepassword';`

And in MySQL configuration file `my.cnf`, comment the line  
`bind-adress = 127.0.0.1`

After restarting mysql engine, test with  
`mysql -u cactiremote -p -h <IP or name of your cacti mysql server> cacti`

# Testing MySQL Connection

You can test the configured MySQL connection within the application in Admin/Global, Maintenance and Tools

# First launch

Job 7 in scheduled tasks permit you to maintain cacti devices list in the application.  
It must runs once before starting collecting data (Job 8).
