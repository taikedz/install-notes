Installing SOGo Groupware solution
===

Lightweight solution to enable shared calendars, resource booking and email delegation.

Alternative to a full-scale Exchange deployment.

Installation on Ubuntu 14.04 server
===

1/ Repository
---

Import signing keys

	sudo apt-key adv --keyserver keys.gnupg.net --recv-key 0x810273C4
	sudo apt-get update

Add to sources.list:

	deb http://inverse.ca/ubuntu trusty trusty

And install

	apt-get install sogo

2/ LDAP setup
---

Install slapd and LDAP maintenance GUI

	apt-get slapd phpldapadmin ldap-utils
	dpkg-reconfigure slapd

Accept most of the defaults, adjusting domain names etc. Note the password

Edit config

	nano /etc/phpldapadmin/config.php

Modify these lines:

	# change hostname
	$servers->setValue('server','host','domain_nam_or_IP_address');
	
	# change dc=test,dc=com to your site's structure
	$servers->setValue('server','base',array('dc=test,dc=com'));
	
	# here too. Note that this will be the superadmin user, using the password set earlier
	$servers->setValue('login','bind_id','cn=admin,dc=test,dc=com');
	
	# uncomment this line and set to true
	// $config->custom->appearance['hide_template_warning'] = false;

Save.

Edit this file

	nano /usr/share/phpldapadmin/lib/TemplateRender.php

On line 2469 change `password_hash` to `password_hash_custom`. Save

3/ Prereqs
---

We'll use the following

Database: MySQL
LDAP: slapd
IMAP: Dovecot
SMTP: Postfix

	apt-get install dovecot-{mysql,ldap,imapd,antispam} postfix{,-{mysql,ldap,doc}}

[This is going to need more work]

TO DO
===

Installing SOGo is proving more challenging than I expected

I was blindly assuming installing things like dovecot and postfix would be super-easy, but turns out I have much to learn.

Not quite the drop-in replacement I was hoping for, but well we gotta learn some day.

Wanted to try configuring just SOGo itself then with optionally LDAP authentication, but using Gmail as mail provider instead... I'll get round to Dovecot and Postfix afterwards when one half of the equation is solved...