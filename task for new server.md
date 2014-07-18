Tasks for a new server
===

After installing a new server, a few extra steps are necessary

Security
---

Edit/create root password -- enable root access

	sudo passwd root

Remove std user from sudo

	sudo gpasswd -d username sudo

At this point, we want to log out as standard user, and log back in to make the change take effect for our current session, and then `su -` to root

Lock down iptables
keep ssh port open, and maybe http/ssl port
Install iptables persist

Install openssh-server
Prevent root login over openssh
	nano /etc/ssh/sshd_config
	--> locate "PermitRoot no" and uncomment it
	restart sshd

install mariadb, php5, apache2
# enable/disable modules:
# a2enmod (module)
# a2dismod (module)
set up root password for database system

Install openvpn to benefit from the ability to manage RSA creation using easy-rsa-2.0 templates
setup certificates for Apache https