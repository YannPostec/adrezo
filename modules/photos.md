You can have photos collection of your IT rooms in adrezo.
By default, they are stored within the application but you can also store them on CIFS share and access them through another web server

# Configuration

Look at those lines in `WEB-INF/web.xml` :

````
<env-entry>
	<description>Photos Location, In Application: /webapp/dir/, with CIFS: http(s)://host/dir/</description>
	<env-entry-name>photo_webhost</env-entry-name>
	<env-entry-type>java.lang.String</env-entry-type>
	<env-entry-value>/adrezo/pictures/</env-entry-value>
</env-entry>
<env-entry>
	<description>CIFS Location of photos : host/dir/</description>
	<env-entry-name>photo_cifshost</env-entry-name>
	<env-entry-type>java.lang.String</env-entry-type>
	<env-entry-value>127.0.0.1/adrezo/</env-entry-value>
</env-entry>
<env-entry>
	<description>Photos File Location : /dir/ If CIFS, allow temporary storage during upload</description>
	<env-entry-name>photo_dir</env-entry-name>
	<env-entry-type>java.lang.String</env-entry-type>
	<env-entry-value>/pictures/</env-entry-value>
</env-entry>
<env-entry>
	<description>false : Storage in app directory. true : Storage on CIFS share</description>
	<env-entry-name>photo_cifs</env-entry-name>
	<env-entry-type>java.lang.Boolean</env-entry-type>
	<env-entry-value>false</env-entry-value>
</env-entry>
````

## photo_webhost
If you store photos inside the application, put here the URI when photos are accessible.  
Usually `/adrezo/pictures/`

Or you could use an external web server with CIFS share configured.
In this case, put here the entire URL
Example : `http://localhost/adrezo/`

__Don't forget to put a slash at the end.__

## photo_cifshost
The CIFS share path in form of `<server IP address or hostname>/<share name>/`  
The share must be configured without authentication and have writable rights.  
__Don't forget to put slash at the end of the share name.__

## photo_dir
The directory used to store photos if photo_cifs is set to false.  
Otherwise it is used to store temporary photo during upload from clients and generate thumbnails.  
It must be writable to the user or group used to launch the application.  
__Don't forget to put slashes at the end and the beginning of this path.__

## photo_cifs
If you want to store photos into the application directory, set this variable to false.  
If you want to store them on CIFS share, set this variable to true.  
It's not possible to have both at the same time.  
If you switch from one mode to the other, you must transfer the already added photos manually.  

# CIFS share example with apache+samba

Just a quick example using Apache web server and Samba to create CIFS share.

### Web.xml example
- photo_webhost : http://localhost/adrezo/
- photo_cifshost : localhost/adrezo
- photo_dir : /pictures/
- photo_cifs : true

### Apache
Within Apache DocumentRoot, create an adrezo directory.  
Change rights to this directory for apache to access it.

### Samba
Create a new share in your samba configuration file pointing to this new directory

````
[adrezo]
   path = <Apache DocumentRoot>/adrezo
   writeable = yes
   read only = no
   browseable = no
   directory mask = 0775
   create mask = 0660
   force user = apache
   force group = apache
   guest ok = yes
   guest only = yes
````
