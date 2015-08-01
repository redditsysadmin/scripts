#!/bin/sh

# Requires ports-mgmt/portmaster and ports-mgmt/portaudit.
hostname=$(hostname)
date=$(/bin/date)

echo "
Updating portaudit first.
"
/usr/local/etc/periodic/security/410.pkg-audit

echo "
Portupdater for ${hostname} started at ${date}


========== Fetching latest ports snapshot from server. ==================
"

if [ $# -lt 1 ]
then
portvar="cron"
else
portvar="fetch"
fi

/usr/sbin/portsnap ${portvar} || exit 1

echo "
========== Updating ports tree with new snapshot. =======================
"
/usr/sbin/portsnap update || exit 1

echo "
============ Cleaning out all obsolete distfiles. =======================
"
/usr/local/sbin/portmaster -y --clean-distfiles || exit 1

if [ ${portvar} = "fetch" ]
then
echo "
Ah, you're actually here. Good.

Running some (possibly) interactive stuff.
"
/bin/sleep 5

echo "
============ Cleaning out stale ports. ==================================
"
/usr/local/sbin/portmaster -s || exit 1
echo "
============ Checking port dependencies. ================================
"
/usr/local/sbin/portmaster --check-depends || exit 1
echo "
============ Cleaning up /var/db/ports. =================================
"
/usr/local/sbin/portmaster --check-port-dbdir || exit 1
fi

echo "
=================== See which ports need updating. ======================
"
/usr/sbin/pkg version -IL '=' || exit 1

echo "
================= Warnings from /usr/ports/UPDATING. ====================
"
weekago=$( /bin/date -v-1w +%Y%m%d )
lastpkg=$( ls -D %Y%m%d -ltr /var/db/pkg | /usr/bin/tail -n1 | /usr/bin/tr -s " " "\t" | /usr/bin/cut -f 6 )
if [ ${weekago} -lt ${lastpkg} ]
 then usedate=${weekago}
 else usedate=${lastpkg}
fi
/usr/sbin/pkg updating -d ${usedate}
echo "
See /usr/ports/UPDATING for further details.

========== Portupdater done. ============================================
"
