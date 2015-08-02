#!/usr/bin/env bash

PATH=${PATH}
source installer/configs/global/install.conf

# Only supporting CentOS 7
puppet-install() {
	rpm -ivh https://yum.puppetlabs.com/el/7/products/x86_64/puppetlabs-release-7-10.noarch.rpm
	yum install puppet
}
puppet-config() {
	echo 'PUPPET_SERVER='${SERVER}'' >> /etc/sysconfig/puppet
	cp installer/configs/linux/auth.conf /etc/puppet/auth.conf
	echo 'server='${SERVER}'' >> /etc/puppet/puppet.conf
}
puppet-cert() {
	puppet agent -v --server ${SERVER} --waitforcert ${TIMEOUT} --test
}
puppet-start() {
	systemctl enable puppet
	systemctl start puppet
}

# Determine if root is running script.
if [ "$(id -u)" == "0" ]; then

	puppet-install
	puppet-config
	puppet-cert
	puppet-start

else
	echo "This script must be run as root."
fi
exit 0
