LetoDMS install notes

1/ Download links

wget http://downloads.sourceforge.net/project/mydms/LetoDMS/LetoDMS-4.0.0-RC1/LetoDMS-4.0.0-RC1.zip
wget http://downloads.sourceforge.net/project/mydms/LetoDMS/LetoDMS-4.0.0-RC1/LetoDMS_Preview-1.0.0.zip
wget http://downloads.sourceforge.net/project/mydms/LetoDMS/LetoDMS-4.0.0-RC1/LetoDMS_Lucene-1.1.1.zip
wget http://downloads.sourceforge.net/project/mydms/LetoDMS/LetoDMS-4.0.0-RC1/LetoDMS_Core-4.0.0RC1.zip

2/ Pre-reqs

Apache, MariaDB, PHP5

3/ Additional items

apt-get install php5-{adodb,gd} libphp-adodb poppler-utils catdoc id3 libzend-framework-php php-pear
php5enmod adodb
pear install HTTP_WebDAV_Server-1.0.0RC8

4/ Create virtual host location and unpack

mkdir /usr/share/webhosts
unzip -d /usr/share/webhosts LetoDMS-4.0.0-RC1
chown -R www-data:www-data /usr/share/webhosts/LetoDMS-4.0.0-RC1

unzip may have created a LetoDMS-4.0.0-RC1 directory inside the LetoDMS-4.0.0-RC1 that is in webhosts - in which case bubble it up.

5/ Create virtual host

cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/letodms.conf
nano /etc/apache2/sites-available/letodms.conf
# configure the site
a2ensite letodms
service apache2 restart

6/ Add db

	CREATE USER 'letodms'@'localhost' IDENTIFIED BY 'letodms';
	GRANT ALL PRIVILEGES ON letodms.* TO 'letodms'@'localhost';
	FLUSH PRIVILEGES;

7/ Go to /use/share/webhosts/LetoDMS-4.0.0-RC1/install

mysql -u letodms -p letodms < create_tables-innodb.sql

