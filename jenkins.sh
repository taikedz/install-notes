#!/bin/bash

apt update && apt install wget

base="https://pkg.jenkins.io/debian-stable/"
deburl="$base/$(wget "$base" -q -O - | grep -Po 'binary/.+?all\.deb' | head -n 1)"

wget "$deburl" -O jenkins.deb
dpkg -i "jenkins.deb" || apt -f install -y

systemctl status jenkins

echo "Initial jenkins key: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
