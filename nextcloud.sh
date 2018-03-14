#!/bin/bash

set -euo pipefail

#%include bashout.sh colours.sh

nc:install_prereqs() {
	apt update || faile "Could not update indexes"
	
	# Core items
	apt install mariadb-server apahce2 php7 libapache2-mod-php7.0 -y

	# PHP supporting modules
	local phpmodules=(
		php7.0-gd
		php7.0-json
		php7.0-mysql
		php7.0-curl
		php7.0-mbstring
		php7.0-intl
		php7.0-mcrypt
		php-imagick
		php7.0-xml
		php7.0-zip
	)
	apt install "${phpmodules[@]}" -y
}

nc:create_datbase() {
	mysql -u root -p -c "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
	# TODO create user here too
	
	# TODO set InnoDB settings:
	#	innodb_large_prefix=on
	#	innodb_file_format=barracuda
	#	innodb_file_per_table=true
}

nc:create_swap() {
	# TODO check memory level
	# enable swap if less than 1024M
}

nc:download_archive() {
	# TODO go to page, identify, download
	# (can we not use Git ...?)
}

nc:unpack_archive() {
	local archive_path="$1"; shift
	local deploy_path="$1"; shift

	mkdir -p "$deploy_path"
	tar xjf "$archive_path" -C "$deploy_path"
}
