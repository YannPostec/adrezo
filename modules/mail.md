The application can send mails to its users.  
In order to send those mails, you need to configure an outgoing mail server.

# Configuration

Modify the following properties in `WEB-INF/classes/adrezo.properties` in order to configure your outgoing mail server :
- mail.host : mail server hostname or ip address
- mail.from : From: mail address
- mail.port : mail server port, integer
- mail.ssl : SSL connexion to the mail server. Permitted values are true and false
- mail.auth : Is there an authentication on the mail server. Permitted values are true and false
- mail.user : In case of authentication, the login to use. Leave empty if mail.auth = false
- mail.pwd : In case of authentication, the password to use. Leave empty if mail.auth = false

# Mail configuration is used in :

- Job 4 : check temporary IP address with date exceeded and advertise users, disabled by default
- Job 5 : check migrating IP address with date exceeded and advertise users, disabled by default
- Job 7 : advertise admin when new devices are found from Cacti database, disabled by default
- Jobs 8 through 10 : advertise admin when something went wrong in statistics gathering or averaging, disabled by default
- Stock : advertise admin when someone change the stock of a supply below threshold defined

You can change mails recipient, subject and message in Admin/Mails within the application.
