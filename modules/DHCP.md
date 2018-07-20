The web application can query api servers (see other project AdrezoDHCP)  
installed on Microsoft Windows Server with DHCP service.  

The list of api servers are defined within the application in `Admin/DHCP`  
The job which query the servers defined and inject ther informations into database is the **Job 11**.  
Activate it in `Admin/Schedule Tasks`

## Configuration

Modify the following properties in `WEB-INF/classes/adrezo.properties` in order to configure timeouts of dhcp server connections :
- dhcp.receive_timeout : Timeout to receive informations from server in milliseconds. Default 5000 (5s)
- dhcp.cnx_timeout : Timeout for server to respond in milliseconds. Default 3000 (3s)
