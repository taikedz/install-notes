Palava.tv on Ubuntu
===

Installing Palava.tv on a fresh Ubuntu Server

Based on https://blog.palava.tv/2013/12/How_to_host_your_own_WebRTC_Video_Conferencing_on_ubuntu/

Someone obviously didn't sanity check the install wiki against a fresh server, or I am missing some knowledge. In any case, the following are the steps I have compiled by actually trying to do this...

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

Right now I'm doing it with root

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

Replace domain with yours of course, on both lines

	export PALAVA_BASE_ADDRESS="http://hu-talk.home" # DOMAIN
	export PALAVA_RTC_ADDRESS="wss://hu-talk.home" # DOMAIN
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

	upstream palava_machine {
	  server 127.0.0.1:4240;
	}

	server {
	  listen 443 ssl;
	  server_name example.com; # TODO

	  ssl on;
	  ssl_certificate /path/to/your/ssl/cert.crt; # TODO
	  ssl_certificate_key /path/to/your/ssl/cert.key; # TODO

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

Now all that needs done is modify the portal now...