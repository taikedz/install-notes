Install eGroupWare on CentOS 6.5
===

What is eGroupWare?
---

eGroupWare aims to be pretty much an all-in-one solution for collaboration in small and medium offices (and even small enterprise). It features calendar and email management, access control lists, a documenbt store, a wiki engine, a site builder, and much more.

What I found
---

Just following a basic install (and I had to refer to other, fairly old blogs to collate this info) doesn't seem to give a ready-to-go setup out fo the box. The interface looks clunky, but mostly intuitive at first, until you actually try to do some proper configuration. I still haven't found out how to set up user groups, the Wiki engine is... very bare bones, despite its WYSIWYG editor (and I see no way to create new wiki pages) and the super user doesn't have rights to view the built-in site area.

As I say, it needs more configuration than the documentation would have you think...

eGroupWare's installation "guide" is pretty sparse and not very clear as well. The guide talks about "EPL" but I think the community edition is non-EPL? Are there actual differences when it comes to installing?

Well, it's clear as mud. These notes are intended to clarify this.

Installation
===

1/ Set up EPEL enterprise
---

Set up EPEL

	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

2/ Enable Remi and update packages
---

Edit /etc/yum.repos.d/remi.repo
Set the [remi] section to enabled=1

then run

	yum install php mysql-server

to update PHP and install MySQL

# run mysqlsetup procedure to set up root access and remove test/demo content

3/ Repo install procedure
---

	cd /etc/yum.repos.d/
	wget http://download.opensuse.org/repositories/server:eGroupWare/CentOS_6/server:eGroupWare.repo
	yum install egroupware-epl

Note we do not have the signing keys for the added repos... will get warning on install

4/ Reconfigure PHP
---

Find these lines and modify

	upload_max_filesize = 16M
	date.timezone = "Europe/London"
	service httpd restart

5/ Add to the web area
---

Add eGroupWare to the std apache install

	ln -s /usr/share/egroupware /var/www/html/egw
	chown -R apache:apache /var/www/html /var/www/html/

6/ Perform web install
---

Go to `http://localhost/egw` and fill in the setup steps

(in future, access this same page via `http://egw/setup/index.php` and log in as header)

Choose to view the `header.inc.php` file; write this to `/var/lib/egroupware/header/inc/php`

7/ Continue steps; login to config with the appropriate creds
---

Provide the db root login and run the install; re-check install, you will need to then set up users

Create an admin user, logout