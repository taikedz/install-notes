#!/bin/bash

set -euo pipefail

wwrun() {
	su -s /bin/bash -c "$*" www-data
}

uask:ask() {
	read -p "$*> "
	echo "$REPLY"
}

uask:confirm() {
	uask:ask "$* y/N>"
	if [[ ! "$REPLY" =~ ^(y|Y|yes|YES)$ ]]; then
		return 1
	fi
	return 0
}

userwait() {
	info "Press return to continue ..."
	read
}

echoe() {
	local clr="$1"; shift
	echo -e "\033[${clr}m$*\033[0m"
}

info() {
	echoe "32;1" "$*"
}

warn() {
	echoe "33;1" "$*"
}

fail() {
	echoe "31;1" "$*"
	exit 1
}

ensure_dir() {
	mkdir -p "$(dirname "$1")"
}

stage_done() {
apt-get update
apt-get install -y apache2 libapache2-mod-php php-imagick gnupg2 php7.0-common mariadb-server git ca-certificates cakephp g++ make mailutils

gpg --gen-key

warn "KEEP NOTE OF THE ABOVE FINGERPRINT"
}

stage_continue() {

ensure_dir "/var/www/passbolt/app/Config/gpg/private.key"
ensure_dir "/var/www/passbolt/app/Config/gpg/public.key"

gpg --armor --export-secret-keys "$email" > /var/www/passbolt/app/Config/gpg/private.key
gpg --armor --export "$email" > /var/www/passbolt/app/Config/gpg/public.key

chown -R www-data:www-data /var/www/passbolt

# =============

git clone https://github.com/passbolt/passbolt_api
cd passbolt_api

chmod +w -R app/tmp
chmod +w app/webroot/img/public

cp app/Config/core.php.default app/Config/core.php

info "Set the following\n"
warn "Configure::write('Security.salt', 'put your own salt here');"
warn "Configure::write('Security.cipherSeed', 'put your own cipher seed here');"
warn "Configure::write('App.fullBaseUrl', 'http://{your domain without slash}');"

userwait

vim app/Config/core.php

cp app/Config/database.php.default app/Config/database.php

info "You need to add the following"
warn "public \$default = array(
    'datasource' => 'Database/Mysql',
    'persistent' => false,
    'host' => 'localhost',
    'login' => 'username',
    'password' => 'password',
    'database' => 'passbolt'
);"

userwait

vim app/Config/database.php

cp app/Config/app.php.default app/Config/app.php

info "Set the following"
warn "\$config = [
    'GPG' => [
        'env' => [
            'setenv' => true,
            'home' => '/usr/share/httpd/.gnupg'
        ],
        'serverKey' => [
            'fingerprint' => '-------- YOUR GPG FINGERPRINT ----------',
            'public' => APP . 'Config' . DS . 'gpg' . DS . 'public.key',
            'private' => APP . 'Config' . DS . 'gpg' . DS . 'private.key',

        ]
    ]
]"

warn "App.ssl.force (true or false, default: true): Defines if passbolt should force ssl connections.

App.registration.public (true or false, default: true): Defines if users can self register, or if only the administrator can create new accounts.

App.meta.robots.index (true or false, default: false): Defines if you want search engines to find and index your instance."

userwait

vim app/Config/app.php

info "Set up email. You can use localhost for the host"

warn "public \$default = array(
    'transport' => 'Smtp',
    'from' => array('passbolt@yourdomain.com' => 'Passbolt'),
    'host' => 'smtp.yourserver.com',
    'port' => 587,
    'timeout' => 30,
    'username' => 'your@email.com',
    'password' => 'password',
);"

vim app/Config/email.php

uask:confirm "Proceed with installation ?" || fail "Abort"

wwrun "app/Console/cake install --no-admin"

wwrun "app/Console/cake passbolt register_user -u '$email' -f '$firstname' -l '$lastname' -r admin"

crontab <( crontab -l | cat - <(echo "* * * * * /var/www/passbolt/app/Console/cake EmailQueue.sender > /var/log/passbolt.log") )

info "You should be sent an email with your activation ..."

info "Completed."
}

main() {
	info "Details eventually needed"
	email="$(uask:ask "Email address")"
	firstname="$(uask:ask "First name")"
	lastname="$(uask:ask "Last name")"

	stage_continue
}

main "$@"
