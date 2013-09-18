#!/usr/bin/env python
#
# sysupdate.py
#
# Version 0.1
#
# Author: Ken MacKenzie
#
# This script uses portsnap to fetch and update the ports tree.  The pkg_version to determine packages that are out of date.
# The user can then specify a line number, No or Yes (to upgrade all) to upgrade packages in the system.  Portupgrade is called
# to perform the upgrade.
#
# Requires:
#
# 1.  Portsnap
# 2.  Portupgrade
# 3.  Python 2.6+
#
# To do:
#
# 1.  Check for sudo/root privledges - DONE
# 2.  Add pkg search and listing features as well as installation of new patches
# 3.  Add version numbers old and new
# 4.  Add log file usage
# 5,  Once a fully functioning and stable CLI tool a GUI tool will be added.

# --Disclamer -- Will not work with new pkgng package manager--#

import os, shlex, subprocess, sys

def PkgsToUpdate():
	print "Checking Package Versions..."
	pvList = []
	pvCmd = "pkg_version -l \"<\""
	pvReturn, pvError = subprocess.Popen([pvCmd], shell=True, stdout=subprocess.PIPE).communicate()
	pvReturn = pvReturn.strip()
	if len(pvReturn):
		pvList = pvReturn.split("\n")
		pvCount = len(pvList)
		pvList = [pvItem.strip(" <") for pvItem in pvList]
	return pvList

os.chdir("/usr/ports")
if not os.getuid()==0:
	print "You do not have root privileges, no system changes can be made."
else:
	print "Refreshing Ports Tree..."
	psCmd = "portsnap fetch update"
	psArgs = shlex.split(psCmd)
	psReturn = subprocess.call(psArgs)
pkgList = []
pkgList = PkgsToUpdate()
if not os.getuid()==0:
	sys.exit("\nRun with root privileges to make changes.\n")
else:
	puExit = 0
	while not(puExit):
		if len(pkgList) == 0:
			print "All packages current."
			puExit = 1
		else:
			print "Packages to upgrade:"
			for x in range ( len(pkgList)):
				print (x+1), " : ", pkgList[x]
			uCmd = raw_input("Enter all (Y)es or (N)o, or enter line number to upgrade individually: ")
			uCmd = uCmd.upper()
			if uCmd == "N":
				puExit = 1
			elif uCmd == "Y":
				for pkgItem in pkgList:
					print "Upgrading package: ", pkgItem
					pkgCmd = "portupgrade " + pkgItem
					pkgArgs = shlex.split(pkgCmd)
					pkgReturn = subprocess.call(pkgArgs)
				pkgList = PkgsToUpdate()
			elif int(uCmd) in range (1, len(pkgList)+1):
				iCmd = int(uCmd)
				print "Upgrading package: ",  pkgList[iCmd - 1]
				pkgCmd = "portupgrade " + pkgList[iCmd - 1]
				pkgArgs = shlex.split(pkgCmd)
				pkgReturn = subprocess.call(pkgArgs)
				pkgList = PkgsToUpdate()
			else:
				print "Invalid Input!!!"
