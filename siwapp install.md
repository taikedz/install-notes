Siwapp installation notes
===

You need to be root

	su -

1/ Download siwapp TGZ
---

	wget http://www.siwapp.org/downloads/siwapp_0_4_1.beta.tar.gz

2/ Unpack
---

	cd /usr/share
	mkdir webhosts
	cd webhosts
	tar -xf siwapp_0_4_1.beta.tar.gz
	chown -R www-data:www-data siwapp

3/ Enable mod_rewrite
---

	a2enmod rewrite

4/ Create virtual host
---

with servername specified to desired

Add this name to whichever /etc/hosts are relevant, as well as the one on the server!

Modify override access to AllowOverride All

5/ install php5-apcu php5-xsl php5-json php5-gd

enable xml2enc if necessary

6/ Restart apache

7/ Create database user

	CREATE USER 'siwapp'@'localhost' IDENTIFIED BY 'siwapp';
	GRANT ALL PRIVILEGES ON siwappdb.* TO 'siwapp'@'localhost';
	CREATE DATABASE siwappdb;
	FLUSH PRIVILEGES;

8/ After running through install pages, remove write access on files:

	chmod a-w /usr/share/siwapp/config/databases.yml /usr/share/siwapp/web/config.php

===
Configure email:
apps/siwapp/config/factories.yml - maybe this has to be changed before running the install?

Effective configuration: /usr/share/webhosts/siwapp/cache/siwapp/prod/config/config_factories.yml.php