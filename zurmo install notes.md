Zurmo installation notes

Download links are at http://zurmo.org/download

e.g. http://build.zurmo.com/downloads/zurmo-stable-2.7.3.9149ccdd67ff.tar.gz

reown
create virtual host
	<Directory /path/to/zurmo>
			Options Indexes FollowSymLinks
			AllowOverride All
			Require all granted
	</Directory>

create user, database
	CREATE USER 'zurmo'@'localhost' IDENTIFIED BY 'zurmo';
	GRANT ALL PRIVILEGES ON zurmodb.* TO 'zurmo'@'localhost';
	FLUSH PRIVILEGES;

apt-get install php5-memcache memcached php-pear build-essential php5-dev mcrypt curl php5-{mcrypt,curl,apcu,ldap,imap,mysql}

# a couple of the INI files do not go to the right place
# only on custom ubuntu apache servers - double check destination!
mv -i /etc/php5/conf.d/*.ini /etc/php5/mods-available/
php5enmod mcrypt
php5enmod imap

# might need to uncomment enablement in conf file
cp /etc/php5/apache2/conf.d/20-memcache.ini /etc/apache2/conf-enabled/

# edit /etc/php5/apache2/php.ini
Set upload_max_filesize to 20M
Set post_max_size to 20M
Set date.timezone = Europe/London

# edit /etc/mysql/my.cnf
# change
max_allowed_packet	= 20M

# in mysql and mysqld sections each, add line
local-infile

# edit /etc/mysql/conf.d/mariadb.cnf
# add lines in [mysqld] group
max_sp_recursion_depth = 20
thread_stack = 512K
optimizer_search_depth = 0
log_bin_trust_function_creators=on