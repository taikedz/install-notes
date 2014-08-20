Palava.tv on Ubuntu
===

Installing Palava.tv on a fresh Ubuntu Server

Based on https://blog.palava.tv/2013/12/How_to_host_your_own_WebRTC_Video_Conferencing_on_ubuntu/

Contrary to my previous notes, it seems someone went and wrote the install steps for a box that had already been in use for development. Here's a re-write for newly-installed Ubuntu-14.04

A reboot is required at some point, need to see if I can avoid doing the install as root next...

Steps
===

Prep
---

The official install notes advise to create a palava user and then switch to it

	adduser palava
	gpasswd -a palava sudo
	su palava
	cd

However the above creates a palava user with sudo access (note, I added that requirement). rvm installation however needs to be root, for the reasons outlined below... this might affect future actions...

	exit # stop being a palava and be root instead again

(ADDENDUM - after a reboot I have rvm as a binary and with a man page; so maybe reboot at this point)

Install ruby
---

Due to the use of `source ...` below, the "rvm" command is not actually a command... not quite sure what it is. Would need to study script, but it's certainly a pain in the ass to use with sudo.

Right now I'm doing it with root; if you've rebooted and logged in as palava, add "sudo" to commands.

	curl -L https://get.rvm.io | sudo bash -s stable
	source /etc/profile.d/rvm.sh
	rvm requirements
	rvm install 1.9.3
	rvm use 1.9.3 --default

Note that 1.9.3 is obsolete -- I'll do a new run once I've got the current instructions down properly

Now go to the palava home directory, and set your group to `palava`

	cd /home/palava
	newgrp palava

This allows the palava user to access the files later... Now download palava repo

	git clone --recursive https://github.com/palavatv/palava-portal.git

Then bundle. This will take some time - about 10min?

	cd palava-portal
	bundle --without development:test --deployment

Replace domain with yours of course, on both lines (note I turned this into non-SSL enabled notation - use https and wss if you want secure comms.)

	export PALAVA_BASE_ADDRESS="http://hu-talk.home" # DOMAIN
	export PALAVA_RTC_ADDRESS="ws://hu-talk.home" # DOMAIN
	bundle exec middleman build

The bundling should take about a minute

Install Redis
---

	apt-add-repository -y ppa:rwky/redis
	apt-get update
	apt-get install redis-server
	sed -e 's/\# bind 127.0.0.1/bind 127.0.0.1/' -i /etc/redis/redis.conf
	service redis-server restart

Install Palava
===

Install the palava gem. Will take a little time, initially might not look like it's doing anything at all...

	gem install palava_machine


... but should complete after spewing out a quite few fetch/install lines

Then create the following in `/etc/init.d/palava-machine`

	#!/bin/bash

	invoke()
	{
	  echo "[$1]"
	  su - palava -c "ruby -S palava-machine-daemon $1"
	}

	start_multiple()
	{
	  if [ "$1" ]
	  then
		n=$1;
	  else
		n=1;
	  fi
	  for (( c=1; c<=n; c++ ))
	  do
		invoke start
	  done
	}

	case "$1" in
	  start)
	  start_multiple "$2"
	  ;;
	  stop)
	  invoke stop
	  ;;
	  *)
	  echo "Usage: service palava-machine {start|stop} [number of instances if start]" >&2
	  exit 3
	  ;;
	esac

Make sure it's executable, then start it

	chmod u+x /etc/init.d/palava-machine
	service palava-machine start

Install nginx
---

	add-apt-repository ppa:nginx/stable
	apt-get update
	apt-get install nginx-full
	touch /etc/nginx/sites-available/palava
	ln -s /etc/nginx/sites-available/palava /etc/nginx/sites-enabled/palava

Edit the file created: `/etc/nginx/sites-available/palava`

Remember to adjust the settings; I'm testing by turning off SSL for staters...

	upstream palava_machine {
	  server 127.0.0.1:4240;
	}

	server {
	  listen 443 ssl;
	  server_name example.com; # CHANGEME

	  ssl on;
	  ssl_certificate /path/to/your/ssl/cert.crt; # CHANGEME
	  ssl_certificate_key /path/to/your/ssl/cert.key; # CHANGEME

	  root /home/palava/palava-portal/build;
	  access_log /home/palava/nginx.access.log;
	  error_log /home/palava/nginx.error.log;

	  location /info/machine {
		proxy_pass http://palava_machine;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_read_timeout 86400;
	  }

	  location / {
		if (-f $request_filename) {
		  break;
		}
		rewrite ^/.+$ / last;
	  }
	}

And then reload the nginx configs

	service nginx reload

Modify the portal
---

Now all that needs done is modify the portal...

Aftermath
===

OK so I am trying to troubleshoot an error: "Unfortunately, the palava rtc server seems to be down! Please try again later!"

I've opened up my firewall completely now, to no avail, so there's something wrong with my config. I did change above configs so that they'd no try to use HTTPS, so maybe this is where I've gone wrong?

I'll try again later. Below I am dumping a full script of the above; tweak as necessary.

Scripts
===

Script 1
---

Creating the palava user. I am now wondering what the point of having a palava user is, since the whole thing runs as a service - why not do the build as root?

	#! /bin/bash
	
	# run as root

	adduser palava
	gpasswd -a palava sudo
	
	su palava
	cd
	
	curl -L "https://get.rvm.io" | sudo bash -s stable
	source /etc/profile.d/rvm.sh
	# still not sure what this sets up; need to read
	reboot

Script 2
---

Majority of the setup

	#! /bin/bash
	sudo rvm requirements
	sudo rvm install 1.9.3
	sudo rvm use 1.9.3 --default

	git clone --recursive "https://github.com/palavatv/palava-portal.git"

	cd palava-portal
	bundle --without development:test --deployment

	export PALAVA_BASE_ADDRESS="https://hu-talk.home" # DOMAIN
	export PALAVA_RTC_ADDRESS="wss://hu-talk.home" # DOMAIN
	bundle exec middleman build

	sudo apt-add-repository -y ppa:rwky/redis
	sudo apt-get update
	sudo apt-get install redis-server
	sudo sed -e 's/\# bind 127.0.0.1/bind 127.0.0.1/' -i /etc/redis/redis.conf
	sudo service redis-server restart

	gem install palava_machine

	cat <<EOF > /etc/init.d/palava-machine
	#!/bin/bash

	invoke()
	{
	  echo "[$1]"
	  su - palava -c "ruby -S palava-machine-daemon $1"
	}

	start_multiple()
	{
	  if [ "$1" ]
	  then
		n=$1;
	  else
		n=1;
	  fi
	  for (( c=1; c<=n; c++ ))
	  do
		invoke start
	  done
	}

	case "$1" in
	  start)
	  start_multiple "$2"
	  ;;
	  stop)
	  invoke stop
	  ;;
	  *)
	  echo "Usage: service palava-machine {start|stop} [number of instances if start]" >&2
	  exit 3
	  ;;
	esac
	EOF

	sudo chmod u+x /etc/init.d/palava-machine
	sudo service palava-machine start

	sudo add-apt-repository ppa:nginx/stable
	sudo apt-get update
	sudo apt-get install nginx-full
	
Script 3
---

nginx preparation. You need to have SSL keys already.

	sudo cat <<EOF >> /etc/nginx/sites-available/palava
	upstream palava_machine {
	  server 127.0.0.1:4240;
	}

	server {
	  listen 443 ssl;
	  server_name hu-talk.home; # CHANGEME

	  ssl on;
	  ssl_certificate /path/to/your/ssl/cert.crt; # CHANGEME
	  ssl_certificate_key /path/to/your/ssl/cert.key; # CHANGEME

	  root /home/palava/palava-portal/build;
	  access_log /home/palava/nginx.access.log;
	  error_log /home/palava/nginx.error.log;

	  location /info/machine {
		proxy_pass http://palava_machine;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
		proxy_read_timeout 86400;
	  }

	  location / {
		if (-f $request_filename) {
		  break;
		}
		rewrite ^/.+$ / last;
	  }
	}
	EOF
	sudo ln -s /etc/nginx/sites-available/palava /etc/nginx/sites-enabled/palava
	sudo service nginx reload