#!/usr/bin/env bash
PATH=${PATH}

# Requires bash, change puppet.master in installer/configs/global/install.conf
# and puppet.agent allow in installer/configs/$platform/auth.conf
echo ""
echo "Make sure you add your clients (puppet agents) to the puppet.master"
echo "config file, located in etc/puppet/manifests/site.pp"
echo ""
sleep 10

# Tested on Freebsd 10.1 and 10.2-BETA.
freebsd-installer() {
	bash installer/freebsd-installer.sh
}

# Tested on OpenBSD 5.7
openbsd-installer() {
	bash installer/openbsd-installer.sh
}

# Tested on CentOS 7.
linux-installer() {
	bash installer/linux-installer.sh
}

# Determine OS as base system layout differs between OS's.
if [ "`uname`" == "FreeBSD" ]; then
	echo "`uname` Detected."
	freebsd-installer
elif
	[ "`uname`" == "OpenBSD" ]; then
	echo "`uname` Detected."
	openbsd-installer
else
	echo "`uname` Detected."
	linux-installer
fi
exit 0
