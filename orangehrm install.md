orangehrm install notes

# ===== Download and unpack

cd /root
wget http://downloads.sourceforge.net/project/orangehrm/stable/3.1.1/orangehrm-3.1.1.zip

apt-get install unzip php5-json php5-gd

cd /usr/share/webhosts/orangehrm
unzip /root/orangehrm-3.1.1.zip > /dev/null

chown -R www-data:www-data

# ===== setup apache environment

a2enmod rewrite

# create virtual host
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/orangehrm.conf
# edit orangehrm.conf and set the ServerName, add the following lines to the conf file

	<Directory /path/to/oranges>
			Options Indexes FollowSymLinks
			AllowOverride All
			Require all granted
	</Directory>

# now run
apachectl restart

# set /etc/hosts in the server and the client to point (ServerName) to the IP of the orangehrm server

# ======== set up database

# In mysql run
	CREATE USER 'orangehrm'@'localhost' IDENTIFIED BY 'orangehrm';
	GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'localhost';
	FLUSH PRIVILEGES;
	SET GLOBAL event_scheduler = 1;

# In /etc/mysql/my.cnf add under [mysqld] section
	event_scheduler=ON

# if you are using MariaDB 10.*
# edit orangehrm-3.1.1/install.php ; find line

	if(intval(substr($mysqlHost,0,1)) < 4 || substr($mysqlHost,0,3) === '4.0')

# change it to

	if(intval(substr($mysqlHost,0,strpos($mysqlHost,"."))) < 4 || substr($mysqlHost,0,3) === '4.0')

# ======== Now go to http://<servername>

Enter the details requested and proceed to install.