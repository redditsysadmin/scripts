#!/usr/bin/env sh

PATH=${PATH}

# Pkgng format only.
puppet-install() {
	pkg update
	pkg install puppet
}

puppet-config() {
	echo 'puppet_enable="YES"' >> /etc/rc.conf
	echo 'puppet_flags="-v --listen --server fbsd-srv02.servebeer.info"' >> /etc/rc.conf
	cp configs/freebsd/auth.conf /usr/local/etc/puppet/auth.conf
}

puppet-cert() {
	puppet agent -v --server fbsd-srv02.servebeer.info --waitforcert 60 --test
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
