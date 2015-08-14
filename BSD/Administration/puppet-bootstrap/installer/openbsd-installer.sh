#!/usr/bin/env bash

PATH=${PATH}
source installer/configs/global/install.conf

# Export remote repo
puppet-install() {
  export PKG_PATH=http://ftp.usa.openbsd.org/pub/OpenBSD/`uname -r`/packages/`arch -s`
  pkg_add puppet
}

puppet-config() {
  mv /etc/puppet/auth.conf /etc/puppet/auth.conf-local
  cp installer/configs/openbsd/auth.conf /etc/puppet/auth.conf
  echo "puppetd=YES" >> /etc/rc.conf.local
  sleep 5
  echo "server = '${SERVER}'" >> /etc/puppet/puppet.conf
}

puppet-cert() {
  echo ""
  echo "Check your puppet.master for a pending cert"
  echo ""
  puppet agent -v --server ${SERVER} --waitforcert ${TIMEOUT} --test
}

puppet-start() {
  /etc/rc.d/puppetd start
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
