#!/usr/bin/env sh

PATH=${PATH}
source installer/configs/global/install.conf

# Pkgng format only.
puppet-install() {
	pkg update
	pkg install puppet
}

puppet-config() {
	echo 'puppet_enable="YES"' >> /etc/rc.conf
	echo 'puppet_flags="-v --listen --server '${SERVER}'"' >> /etc/rc.conf
	cp installer/configs/freebsd/auth.conf /usr/local/etc/puppet/auth.conf
}

puppet-cert() {
	puppet agent -v --server ${SERVER} --waitforcert ${TIMEOUT} --test
}

puppet-start() {
	service puppet start
}

if [ "$(id -u)" == "0" ]; then

	puppet-install
	puppet-config
	puppet-cert
	puppet-start

else
	echo "This script must be run as root."
fi
exit 0
