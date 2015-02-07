# Notes after installation of squid3 proxy from Ubuntu 14.04 repos

It's hard to come by straight forward instructions to install a squid proxy server... granted, squid is powerful and vast, so there's a lot of discussion, but here's a very basic primer, for Ubuntu 14.04.1 servers.

## Installing from repo

All operations are of course to be performed as root.

	apt update && apt install squid3 squidclient

This will install squid3 with defaults.

View the default settings with this command:

	grep -v ^# /etc/squid3/squid.conf | grep -v ^$

It effectively omits all comments and blank lines :-)

## Configuration

Edit the /etc/squid3/squid.conf file

You will find that it is _riddled_ with documentation that may be overwhelming. Use the find function of your editor to hop to the right places. All directives start at the beginning of the line, so if you can search using regexes, use the '^#?\s*' pattern before a directive to speed things up. (this matches start of line, maybe a '#' commentor, and potential whitspace)

### Port

By default, the squid proxy's port is 3128, declared by the `http_port` directive. I changed mine to 80, you could change it to 8080, or anything you wish... just remember to configure the firewall appropriately.

### Cache directory configuration

You may also want to configure the location of the cached files, and their quantity, which you can find at the directive `cache_dir`

	cache_dir ufs /home/proxy/cache/ 5000 32 256

I moved mine to /home/proxy/cache/ after creating the needed directories, because I had more space on /home partition than in root, but this is up to you. You could mount another drive and point the cache_dir there. You can have as many cache_dir locations as you want.

The '50000' is the number of megabytes of cache to maintain - in this instance, shy of 5GB. 'ufs' is the squid storage type, and the last two numbers are the number of subdirectories to create. Read the paragraph preceding this directive in the conf file for more info.

## Configure the firewall

You need at minimum to allow

* input on the port you specifid squid to listen on
* forwarding

The firewalling script at https://github.com/handy-scripts in bin/firewall gives you sane defaults for this.

## Restart squid proxy

Run

	service squid3 restart

to restart the squid proxy with the new configuration.

## Configure your clients

Configure your HTTP clients now. The setup allows HTTP and HTTPS requests through, and caches responses.

For Firefox, go to [menu] : Preferences : Advanced : Network , under "Connection" edit "Settings"

Choose to use Manual proxy configuration, and point it at your server's name, and the port you set squid up on. Consider specifying No Proxy for: with

	localhost, 127.0.0.1

Click OK. This should be all you need.
