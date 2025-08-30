#!/bin/bash

# Tonton Jo - 2025
# Join me on Youtube: https://www.youtube.com/c/tontonjo

# This little tool is aimed to set some default configurations up and running in not time

# DISCLAIMER
# I assume you know what you are doing have a backup and have a default configuration.
# I'm responsible in no way if something get broken - even if there's likely no chance to happen:-)
# I am no programmer - just tying to get some begginers life a bit easier
# There will be bugs or things i did not thinked about - sorry - if so, try to solve-it yourself, let me kindly know and PR
# Backup and restore has not been extensivly tested - and has never been tested on cluster configurations - Dont count on it too much

# USAGE
# You can download and execute this script using:
# wget -qO proxmox_toolbox.sh https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh && bash proxmox_toolbox.sh

# SOURCES:
# https://pve.proxmox.com/wiki/Fail2ban
# https://pve.proxmox.com/wiki/System_Software_Updates
# https://forum.proxmox.com/threads/how-do-i-set-the-mail-server-to-be-used-in-proxmox.23669/
# https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0

# https://www.linuxtricks.fr/wiki/proxmox-quelques-infos

# https://github.com/inettgmbh/fail2ban-proxmox-backup-server
# https://linuxscriptshub.com/configure-smtp-with-gmail-using-postfix/
# https://suoption_pickedpport.google.com/accounts/answer/6010255
# https://www.howtoforge.com/community/threads/solved-problem-with-outgoing-mail-from-server.53920/
# http://mhawthorne.net/posts/2011-postfix-configuring-gmail-as-relay/
# https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/add-ssh-enabled-user.html
# https://www.noobunbox.net/serveur/monitoring/configurer-snmp-v3-sous-debian
# https://blog.lbdg.me/proxmox-best-performance-disable-swappiness/
# https://gist.github.com/mrpeardotnet/6bdc4b504f43ce57fa7eaee96d376edf
# https://github.com/DerDanilo/proxmox-stuff/blob/master/prox_config_backup.sh


# TODO:
# settings for zram -> https://pve.proxmox.com/wiki/Zram
# PBS: add support for user creation and backup / restoration
# make things stupid-proof (deny characters when numbers expected ans so on)
# Cosmetic corrections

# Proxmox_toolbox
version=5.3.0

# V1.0: Initial Release
# V1.1: correct detecition of subscription message removal
# V2.0: Add backup and restore - reworked menu order - lots of small changes
# V2.2: add confirmation to disable root@pam which is required to update from web UI - add more choices in security settings
# V2.3: Add check of swap existence to allow swap setting configuration
# V2.4: Add check of root rights
# V2.5: Ensure swap setting resist reboot
# V2.6: Much better and smarter way to remove subscription message (credits to @adrien Linuxtricks)
# V2.7: Fix remove subscription message detection
# V3.0: Remove useless mutiple versions for better clarity
# V3.1: Merge backup folder in case there's pve and pbs on the same host - useless to have 2 content list
# V3.2: Restauration now automatically remount directories and reimport existant zpools
# V3.3: Add echo when restarting proxy services
# V3.4: Add proxmox bashrc command to invoke update script usinge "proxmox-update"
# V3.4.1: reverted.
# V3.5: In order to have 1 tool and be able to simply update with ease, now it can be triggered using the -u flag
# V3.6: reworked a bit the snmp menu for better clarity & use systemctl everywhere
# V3.7: Add check when restoring "dir" to ensure the original drive still resides in system to avoid problems at boot
# V3.8: Use /usr/bin instead of .bashrc edit - way better
# V3.8.1: Little enhancement for updates
# V3.9.0: Fix update who happend to not work on first run for no apparent reasons and remove ping in mail menu
# V3.9.1: Add more logic when creating new admin user
# V3.9.2: Specify more clearly the realm to use when creating an alternate admin user
# V3.9.3: Add check for .mount file to avoid error trying to remount
# V3.9.4: Fix detection of enterprise source status in order to not reapply
# V3.9.5: Fix snmp file retreiving - add a success validation befor continuing.
# V3.9.6: add choice to restore the network configuration usefull in case of other network configuration / hardware
# V3.9.7: Add a first run backup for people who rekt their installation and blame the toolbox :) - add some enhancements
# V3.9.8: Uninstall fail2ban when restoring if no config exist in backup content
# V3.9.9: Small cosmetic changes and enhancements, now check for update bin version
# V4.0.0: Some cosmetic changes
# V4.0.1: Small enhancement for backup / restore function - bump bin version to 1.2
# V4.0.2: Small enhancements
# V4.0.3: Update sources before attempt to install packages and ensure git is installed before trying to clone
# V4.1.0: Correction and optimisations in fail2ban setup
# V4.1.1: Important fix in permissions for ssh keys
# V4.1.2: Add Ceph enterprise list to ignored sources when using no-subcription
# V4.1.3: Add a function to restore a working self-signed certificate in case of mistake, replace sleep with a more permissive method
# V4.1.4: reworked menu a bit
# V4.1.5: Fixed fail2ban in proxmox V8 - needed to add "backend = systemd" in every jail
# V4.1.6: Small add to pbs in order to support case where the source.list file is missing (docker container)
# V4.2.0: Add argument to run backup directly
# V4.2.1: Notifications now use hostname in from instead of "root"
# V4.2.2: Add a corosync file to backup content as it appear to be necessary to restore a node in a cluster -> https://github.com/Tontonjo/proxmox_toolbox/issues/19
# V4.2.3: fixed snmpd dependencies installation check to be more reliable
# V4.2.4: Added Rsyslog as it's missing in pve8 and can be usefull to check logs (merci l'ami)
# V4.3.0: Removed email options as pve8 has now a gui configuration tool that is way better. hidden in menu 9 in case :)
# V4.3.1: Removed apt upgrade in update as it's useless and less safe thant apt dist-upgrade
# V5.0.0: Support for PVE 9, enhancements and error management in the security settings
# V5.0.1: Some more corrections
# V5.1.0: Corrected sources configurations to support PBS correctly
# V5.2.0: Corrected and enhanced No subscription message removal 
# V5.2.1: fixed detection of no subscription sources 
# V5.2.2: fixed detection of fail2ban configuration, added some comments and Cosmetic changes
# V5.2.3: Suggest to modernize sources if an upgrade is detected
# V5.3.0: usefull dependencies: Suggest to enable non-free-firmware in sources configurations and install amd-64-microcode (suggested as per pve8to9)

# check if root
if [[ $(id -u) -ne 0 ]] ; then echo "- Please run as root / sudo" ; exit 1 ; fi

# -----------------User variables----------------------
backupdir="/root/proxmox_config_backups" # NO trailing slash is mandatory
backup_content="/etc/ssh/sshd_config /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/pve/ /etc/lvm/ /etc/modprobe.d/ /var/lib/pve-firewall/ /var/lib/pve-cluster/ /etc/corosync/authkey /etc/vzdump.conf /etc/ksmtuned.conf /etc/proxmox-backup/"

# ----------------- System variables----------------------
updatebinversion=1.2
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
execdir=$(dirname $0)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)
# ---------------END OF VARIABLES-----------------



if [ ! -f /root/proxmox_config_backups/$hostname-firstrun.tar.gz ]; then
	echo "- Creating a backup at first run - dont delete it :-)"
	mkdir -p /root/proxmox_config_backups/
	tar -czf /root/proxmox_config_backups/$hostname-firstrun.tar.gz --absolute-names $backup_content
	echo "- First run: a backup of the actual configurations has been created at /root/proxmox_config_backups/$hostname-firstrun.tar.gz"
	wait_or_input
fi

## Functions
# Function to wait an amount of time or a key press
wait_or_input() {
  local timeout=30 # timeout
  local input

  if read -t "$timeout" -n 1 -p "- Continue: press any key or wait $timeout seconds... " input; then
    echo "Key pressed: continuing"
  else
    echo "- No key pressed until $timeout tiemout. continuing..."
  fi
}
# Update 
update () {
		# Check if the /usr/bin/proxmox-update entry for update is already created
		if ! grep -Fqs "$updatebinversion" /usr/bin/proxmox-update; then
		    	echo "- Downloading / Updating update binary to version $updatebinversion"
			wget -qO "/usr/bin/proxmox-update" https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/bin/proxmox-update && chmod +x "/usr/bin/proxmox-update"
			update
		else
			echo "- Updating System using proxmox_toolbox.sh version $version"
			apt-get update -y -qq
			apt-get dist-upgrade -y -qq
			# We check for new source files first in case the sources arent modernized
			if [[ -f /etc/apt/sources.list.d/proxmox.sources ]]; then
			# Check if the js file is already modified to bypass no subscription message
				if grep -q "res\.data\.status\.toLowerCase() *==\{0,2\} *'active'" $proxmoxlib; then
					echo "- Subscription Message already removed - Skipping"
				else
					if [ -d "$pve_log_folder" ]; then
						echo "- Removing No Valid Subscription Message for PVE"
						sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart pveproxy.service
					else 
						echo "- Removing No Valid Subscription Message for PBS"
						sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart proxmox-backup-proxy.service
					fi
				fi
			# Then we check for old sources list entries
			elif grep -Ewqi "no-subscription" /etc/apt/sources.list; then
			    # Check if the js file is already modified to bypass no subscription message (need to match old erroneous == )
				if grep -q "res\.data\.status\.toLowerCase() *==\{0,2\} *'active'" $proxmoxlib; then
					echo "- Subscription Message already removed - Skipping"
				else
					if [ -d "$pve_log_folder" ]; then
						echo "- Removing No Valid Subscription Message for PVE"
						sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart pveproxy.service
					else 
						echo "- Removing No Valid Subscription Message for PBS"
						sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart proxmox-backup-proxy.service
					fi
				fi
			fi
		fi
}
# get the snmp configurations 
snmpconfig() {
wget -qO /etc/snmp/snmpd.conf https://github.com/Tontonjo/proxmox_toolbox/raw/main/snmp/snmpd.conf
}

sources_conf_pve () {
if [ "$proxmox_version" -ge 9 ]; then
if [[ ! -f /etc/apt/sources.list.d/proxmox.sources ]]; then
  echo "- Configuring No-Subscription for Proxmox VE $proxmox_version"
  cat > /etc/apt/sources.list.d/proxmox.sources << EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: $distribution
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
else
  echo "-- No enterprise sources already configured - skipping"
fi
	# --- Désactivation Enterprise ---
	if [[ -f /etc/apt/sources.list.d/pve-enterprise.sources ]]; then
	  echo "-- Commenting PVE Enterprise repo (backup)"
	  mv /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/pve-enterprise.sources.BAK
	fi
	# --- Désactivation Ceph Enterprise ---
	if [[ -f /etc/apt/sources.list.d/ceph.sources ]]; then
	  echo "-- Comment Ceph enterprise repo (backup)"
	  mv /etc/apt/sources.list.d/ceph.sources /etc/apt/sources.list.d/ceph.sources.BAK
	fi
	if grep -q "^[[:space:]]*deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list; then
		echo "-- Found active Proxmox no subscription repo, commenting it..."
		sed -i "/^[[:space:]]*deb http:\/\/download\.proxmox\.com\/debian\/pve $distribution pve-no-subscription/ s/^/# /" /etc/apt/sources.list
		read -p "!! Looks like you upgraded your proxmox instance, it is recommanded to run \"apt modernize-sources\" !! execute? y = yes / ANYTHING = no: " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			apt modernize-sources
        fi
	fi

files=(
    "/etc/apt/sources.list.d/pve-enterprise.list"
)
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "- Deleting old source list $file"
        rm -f "$file"
    fi
done
apt-get update -qq
else
  echo "- Configuring No-Subscription for Proxmox VE $proxmox_version"
  if grep -Fq "deb http://download.proxmox.com/debian/pve" /etc/apt/sources.list; then
    echo "-- No enterprise Source already configured - Skipping"
  else
    echo "-- Adding new entry to sources.list"
    sed -i "\$adeb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
  fi

  echo "- Checking Enterprise Source list"
  if grep -Fq "#deb https://enterprise.proxmox.com/debian/pve" "/etc/apt/sources.list.d/pve-enterprise.list"; then
    echo "-- Enterprise repo looks already commented - Skipping"
  else
    echo "-- Hiding Enterprise sources list"
    sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
  fi

  echo "- Checking Ceph Enterprise Source list"
  if [[ -f "/etc/apt/sources.list.d/ceph.list" ]]; then
    if grep -Fq "#deb https://enterprise.proxmox.com/debian/ceph-quincy" "/etc/apt/sources.list.d/ceph.list"; then
      echo "-- Ceph Enterprise repo looks already commented - Skipping"
    else
      echo "-- Hiding Ceph Enterprise sources list"
      sed -i 's/^/#/' /etc/apt/sources.list.d/ceph.list
    fi
  fi
fi

}

sources_conf_pbs () {
if [ "$pbs_version" -ge 4 ]; then
if [[ ! -f /etc/apt/sources.list.d/proxmox.sources ]]; then
  echo "- Configuring No-Subscription for Proxmox Backup Server $pbs_version"
  cat > /etc/apt/sources.list.d/proxmox.sources << EOF
Types: deb
URIs: http://download.proxmox.com/debian/pbs
Suites: $distribution
Components: pbs-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
else
  echo "-- No enterprise sources already configured - skipping"
fi

if [[ -f /etc/apt/sources.list.d/pbs-enterprise.sources ]]; then
  echo "-- Comment Enterprise PBS repo (backup)"
  mv /etc/apt/sources.list.d/pbs-enterprise.sources /etc/apt/sources.list.d/pbs-enterprise.sources.BAK
fi

if grep -q '^[[:space:]]*deb http://download.proxmox.com/debian/pbs' /etc/apt/sources.list; then
    echo "-- Found active Proxmox Backup no-subscription repo in sources.list, commenting it..."
    sed -i '/^[[:space:]]*deb http:\/\/download\.proxmox\.com\/debian\/pbs/ s/^/# /' /etc/apt/sources.list
	read -p "!! Looks like you upgraded your proxmox instance, it is recommanded to run \"apt modernize-sources\" !! execute? y = yes / ANYTHING = no: " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		apt modernize-sources
    fi
fi

# --- Suppression anciens fichiers list éventuels ---
files=(
    "/etc/apt/sources.list.d/pbs-enterprise.list"
)
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "- Deleting old source list $file"
        rm -f "$file"
    fi
done
apt-get update -qq
else
	echo "- Configuring No-Subscription for Proxmox Backup Server $pbs_version"
  if grep -Fq "deb http://download.proxmox.com/debian/pbs" /etc/apt/sources.list; then
    echo "-- PBS source already configured - Skipping"
  else
    echo "-- Adding PBS entry to sources.list"
    sed -i "\$adeb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list
    exitcode=$?
    if [ $exitcode -ne 0 ]; then
      echo "-- sources.list seems to be missing as sed failed: creating it in /etc/apt/sources.list"
      if [ -f "/etc/apt/sources.list" ]; then
        echo "-- sources.list appears to exist but an error was encountered. Please report this case on GitHub."
      else
        echo "-- Creating sources.list"
        echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list
        wget -q https://enterprise.proxmox.com/debian/proxmox-release-$distribution.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg
      fi
    fi
  fi

  echo "- Checking PBS Enterprise Source list"
  if grep -Fq "#deb https://enterprise.proxmox.com/debian/pbs" /etc/apt/sources.list.d/pbs-enterprise.list; then
    echo "-- PBS Enterprise repo looks already commented - Skipping"
  else
    echo "-- Hiding PBS Enterprise sources list"
    sed -i 's/^/#/' /etc/apt/sources.list.d/pbs-enterprise.list
  fi
 fi
}


# Display the banner in menu
banner() {
    echo -e "${MENU}****************** Proxmox Toolbox **********************${NORMAL}"
    echo -e "${MENU}*********** Tonton Jo - 2023 - Version $version ************${NORMAL}"
    echo -e "${MENU}********** https://www.youtube.com/c/tontonjo **********${NORMAL}"
	echo -e "${MENU} " "${NORMAL}"
}

# Validate that a content retreiving was successfull
getcontentcheck() {
exitcode=$?
if [ $exitcode -ne 0 ]; then
	echo "- Error retreiving ressources - control your internet connexion"
	wait_or_input
	main_menu
fi
}
# backup the configurations
backup() {
mkdir -p $backupdir
echo "- Creating backup"
tar -czf $backupdir/$hostname-$(date +%Y_%m_%d-%H_%M_%S).tar.gz --absolute-names $backup_content
clear
echo "-- Backup done at $backupdir - please control and test it"
}
# Arguments
# Thoses are argument that directly trigger specific toolbox functions
if  [[ $1 = "-u" ]]; then
update
exit
fi

if  [[ $1 = "-b" ]]; then
backup
exit
fi
# End of arguments

main_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
	banner
    echo -e "${MENU}****************** Main menu **********************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} No-subscription Sources Configuration ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Update host & create proxmox-update command ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Install usefull dependencies ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Security settings (fail2ban - SSH user - GUI Administrator) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} SWAP Settings ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Enable S.M.A.R.T self-tests ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 7)${MENU} SNMP settings ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 8)${MENU} PVE / PBS Configurations backup and restoration ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Exit ${NORMAL}"
    echo " "
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option number or ${RED_TEXT}enter to exit. ${NORMAL}"
    read -rsn1 opt
	while [ opt != '' ]
  do
    if [[ $opt = "" ]]; then
      exit;
    else
      case $opt in

	  	  1) clear;
		read -p "This will configure sources for no-enterprise repository - Continue? y = yes / ANYTHING = no: " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then
  			echo " "
			if [ -d "$pve_log_folder" ]; then
				proxmox_version=$(pveversion | cut -d'/' -f2 | cut -d' ' -f1 | cut -d'.' -f1)
				sources_conf_pve
				wait_or_input
			else
				pbs_version=$(proxmox-backup-manager version | awk '{print $2}' | cut -d'.' -f1)
				sources_conf_pbs
				wait_or_input
			fi
		fi
		main_menu
	   ;;
	   	  2) clear;
		update
		wait_or_input
		main_menu
	   ;;
      3) clear;
			read -p "- This will install thoses libraries if missing: ifupdown2, git, sudo, libsasl2-modules, lshw, lm-sensors - Continue? y = yes / ANYTHING = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo " "
				echo "- Updating sources"
				apt-get update -y -qq
				if [ $(dpkg-query -W -f='${Status}' ifupdown2 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y ifupdown2;
				else
					echo "- ifupdown2 already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y git
				else
					echo "- git already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y sudo
				else
					echo "- sudo already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' libsasl2-modules 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y libsasl2-modules
				else
					echo "- libsasl2-modules already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' lshw 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y lshw
				else
					echo "- lshw already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' 3 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y lm-sensors
				else
					echo "- lm-sensors already installed"
				fi
    				if [ $(dpkg-query -W -f='${Status}' rsyslog 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y rsyslog
				else
					echo "- rsyslog already installed"
				fi
				read -p "- Enable non-free-firware sources and install amd64-microcode? y = yes / ANYTHING = no: " -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
						sed -i '0,/^Components: main contrib$/s//Components: main contrib non-free-firmware/' /etc/apt/sources.list.d/debian.sources
					elif [[ -f "/etc/apt/sources.list" ]]; then
						sed -i '0,/main contrib/s/^\(.*main contrib\)\(.*\)$/\1 non-free-firmware\2/' /etc/apt/sources.list
					fi
					apt-get update
					apt-get install amd64-microcode
				fi
				
			wait_or_input
			fi	
		main_menu
      ;;
	4) clear;
		read -p "== Do you want to enable fail2ban? y = yes / ANYTHING = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo " "
				echo "- Updating sources"
				apt-get update -y -qq
				if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y fail2ban;
					getcontentcheck
				else
					echo "- fail2ban already installed"
				fi
				echo "- Ensuring Git is installed"
				if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y git;
					getcontentcheck
				else
					echo "- git already installed"
				fi
					echo "- Retreiving fail2ban Proxmox jails from github"
					git clone -q https://github.com/Tontonjo/proxmox_toolbox.git
					getcontentcheck
				if [ -d "$pve_log_folder" ]; then
					echo "- Host is a PVE Host"
					# Put filter.d/proxmox-backup-server.conf contents to /etc/fail2ban/filter.d/proxmox-backup-server.conf
					cp -f proxmox_toolbox/pve/filter.d/proxmox-virtual-environement.conf /etc/fail2ban/filter.d/proxmox-virtual-environement.conf
					# Put jail.d/proxmox-backup-server.conf to /etc/fail2ban/jail.d/proxmox-backup-server.conf
					cp -f proxmox_toolbox/pve/jail.d/proxmox-virtual-environement.conf /etc/fail2ban/jail.d/proxmox-virtual-environement.conf
				else
					echo "- Host is a PBS Host"
					# Put filter.d/proxmox-backup-server.conf contents to /etc/fail2ban/filter.d/proxmox-backup-server.conf
					cp -f proxmox_toolbox/pbs/filter.d/proxmox-backup-server.conf /etc/fail2ban/filter.d/proxmox-backup-server.conf
					# Put jail.d/proxmox-backup-server.conf to /etc/fail2ban/jail.d/proxmox-backup-server.conf
					cp -f proxmox_toolbox/pbs/jail.d/proxmox-backup-server.conf /etc/fail2ban/jail.d/proxmox-backup-server.conf
				fi
    				# Adding the right backend to fail2ban sshd configuration
				if ! grep -Fqs "systemd" /etc/fail2ban/jail.d/defaults-debian.conf; then
    				echo "- Backend missing in defaults-debian.conf"
    				echo -e "\nbackend = systemd" >> /etc/fail2ban/jail.d/defaults-debian.conf
    				else
				echo "- Backend already setted-up in defaults-debian.conf"
				fi
#    				if [ -d "$pve_log_folder" ]; then
#	    				if ! grep -Fqs "systemd" /etc/fail2ban/jail.d/proxmox-virtual-environement.conf; then
#	    				echo "- Backend missing in proxmox-virtual-environement.conf"
#	    				echo -e "\nbackend = systemd" >> /etc/fail2ban/jail.d/proxmox-virtual-environement.conf
#	    				else
#					echo "- Backend already setted-up in proxmox-virtual-environement.conf"
#					fi
#    				else
#	        			if ! grep -Fqs "systemd" /etc/fail2ban/jail.d/proxmox-backup-server.conf; then
#	    				echo "- Backend missing in proxmox-backup-server.conf"
#	    				echo -e "\nackend = systemd" >> /etc/fail2ban/jail.d/proxmox-backup-server.conf
#	    				else
#					echo "- Backend already setted-up in proxmox-backup-server.conf"
#					fi
#    				fi
				# Restart Fail2Ban Service
				echo "- Restarting fail2ban service"
				systemctl restart fail2ban.service
    				if systemctl is-active fail2ban | grep -q 'active'; then
					echo "- Fail2ban started correctly"
				else
    					echo "- Fail2ban failed to start"
	 				systemctl status fail2ban
    				fi
				echo "- Cleaning git ressources"
				rm -rf ./proxmox_toolbox/
    				wait_or_input
			fi
		clear
		echo "== Do you want to create another SSH user ?"
		echo "- This will guide you to create another user, add it as a sudo user and allow sudo users to connect trough ssh"
		read -p "- Press: y = yes / ANYTHING = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				clear
				if [ $(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y sudo
					getcontentcheck
				else
					echo "- sudo already installed"
				fi
				echo "- What is the new debian user username?: "
				read username
				clear
				useradd -m $username
				passwd $username
				mkdir /home/$username/.ssh/
				ssh-keygen -t rsa -b 4096 -f /home/$username/.ssh/id_rsa -q -N ""
				cp /home/$username/.ssh/id_rsa.pub /home/$username/.ssh/authorized_keys
				chown -R $username:$username /home/$username/.ssh/
				echo "- New user $username created"
				echo "- Adding user to sudo users"
				adduser $username sudo
				echo "AllowGroups sudo" >> "/etc/ssh/sshd_config"
				read -p "== Do you want to deny root SSH login?  y = yes / anything = no: " -n 1 -r
					if [[ $REPLY =~ ^[Yy]$ ]]; then
						if grep -qF "PermitRootLogin yes" /etc/ssh/sshd_config; then
							sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
						fi
				systemctl restart ssh sshd
					fi
				clear
			fi
			clear
			if [ -d "$pve_log_folder" ]; then
					read -p "== Do you want to create an alternate PVE admin user? y = yes / ANYTHING = no: " -n 1 -r
					if [[ $REPLY =~ ^[Yy]$ ]]; then
						clear
						echo "- What is the new pve username: "
						read pveusername
						# Check if the user already exists
						if pveum user list | grep -q "$pveusername@pve "; then
							echo "  -> User $pveusername already exists, skipping."
						else
							echo "- Creating PVE user $pveusername"
							pveum user add "$pveusername@pve"
							# Retry if the command fails
							while [ $? -ne 0 ]; do
								echo "  -> Failed to create user $pveusername (exit code $?), retrying..."
								sleep 1
								pveum user add "$pveusername@pve"
							done
							echo "  -> User $pveusername created successfully."
						fi
						echo "- Setting password for $pveusername"
						pveum passwd "$pveusername@pve"
						while [ $? -ne 0 ]; do
							echo "  -> Failed to set password (exit code $?), retrying..."
							sleep 1  # optional delay
							pveum passwd "$pveusername@pve"
						done

						echo "  -> Password set successfully for $pveusername."
						echo " "
						echo "- What is the new admin group name: "
						read admingroup	
						# Check if the group already exists
						if pveum group list | grep -q "$admingroup" ; then
							echo "  -> Group $admingroup already exists, skipping."
						else
							pveum group add "$admingroup" -comment "System Administrators"
							echo "  -> Group $admingroup created successfully."
						fi
						echo "- Defining administrators right"
						# Check if the group already has the Administrator role on /
						if pveum acl list | grep -q "Administrator" | grep -q $admingroup ; then
							echo "  -> $admingroup already has Administrator rights, skipping."
						else
							pveum acl modify / -group "$admingroup" -role Administrator
							echo "  -> Administrator rights assigned to $admingroup."
						fi

						echo "- adding $pveusername to $admingroup"
							pveum user modify "$pveusername"@pve -group "$admingroup"
				
						echo "- You should now be able to login on GUI with $pveusername@Proxmox VE authenticaton Realm"
						wait_or_input
						echo " "
						echo "!! Warning - root@pam is required to update host from Proxmox web ui !!"
						read -p "== Do you want to disable "root@pam"?  y = yes / ANYTHING = no: " -n 1 -r
						if [[ $REPLY =~ ^[Yy]$ ]]; then
							clear
							read -p "- Are you sure you want to disable root@pam? y = yes / ANYTHING = no: " -n 1 -r
								if [[ $REPLY =~ ^[Yy]$ ]]; then
									echo "- Removing root user from PVE"
									pveum user modify root@pam -enable 0
								fi
						fi
					fi
					clear

				else
					echo "- Host is a PBS host - user management not implemented ATM"
			fi
		main_menu
	   ;;
	   5) clear;
		lsblk | grep -qi swap
		swapenabled=$?
	   	if [ $swapenabled -eq 0 ]; then
		echo ""
		swapvalue=$(cat /proc/sys/vm/swappiness)
		echo "- SWAP is actually set on $swapvalue"
		echo "- Recommanded value: 1 - The lower the value - the less SWAP will be used - 0 to use SWAP only when out of memory"
		read -p "- Do you want to edit swappiness value or disable SWAP? y = yes / ANYTHING = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo ""
				echo "- What is the new swapiness value? 0 to 100 "
				read newswapvalue
				echo "- Setting swapiness to $newswapvalue"
				sysctl vm.swappiness=$newswapvalue
				echo "vm.swappiness=$newswapvalue" > /etc/sysctl.d/swappiness.conf
				echo "- Emptying swap - This may take some time"
				swapoff -a
				echo "- Re-enabling with a swapiness of: $newswapvalue"
				swapon -a
				wait_or_input
			fi
		else
			echo " - System has no swap - Nothing to do"
			wait_or_input
		fi
		main_menu
      ;;
	   6) clear;
	   	read -p "- Do you want to enable short and long S.M.A.R.T self-tests? y = yes / ANYTHING = no: " -n 1 -r
		clear
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				if grep -Ewqi "(S/../../7/22|L/../01/./22)" /etc/smartd.conf; then
					echo "- Self tests looks already configured"
					echo "- Short smart test will occure every sunday at 22H and long smart tests every 1 of month at 22H"
				else
					cp /etc/smartd.conf /etc/smartd.conf.BCK
					echo "- Enabling short and long self-tests"
					echo "- Short smart test will occure every sunday at 22H and long smart tests every 1 of month at 22H"
					echo "DEVICESCAN -d auto -n never -a -s (S/../../7/22|L/../01/./22) -m root -M exec /usr/share/smartmontools/smartd-runner" > "/etc/smartd.conf"
				fi
			wait_or_input
			fi
		main_menu
      ;;
	   7) clear;
		read -p "- Install and configure SNMP? y = yes / anything = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo " "
				if [ $(dpkg-query -W -f='${Status}' git 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y git;
				else
					echo "- git already installed"
				fi
				git clone -q https://github.com/Tontonjo/proxmox_toolbox.git
				if [ $(dpkg-query -W -f='${Status}' snmpd 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y snmpd;
				else
					echo "- snmpd already installed"
				fi
    				if [ $(dpkg-query -W -f='${Status}' libsnmp-dev 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y libsnmp-dev;
				else
					echo "- libsnmp-dev already installed"
				fi
				clear
				read -p "- Press 2 for snmpv2 or 3 for SNMP V3 (ReadOnly) or anything to return to menu: " -n 1 -r
				if [[ $REPLY =~ ^[2]$ ]]; then
					clear
					cp -n /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.backup
					snmpconfig
					getcontentcheck
					echo "- Read only community name? (ex: ro_tontonjo): "
					read rocommunity
					echo "- Allowed subnet? Enter for none (x.x.x.x/xx): "
					read allowedsubnet
					echo "- Setting SNMP"
					echo "rocommunity $rocommunity $allowedsubnet" >> /etc/snmp/snmpd.conf
				elif [[ $REPLY =~ ^[3]$ ]]; then
					clear
					cp -n /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.backup
					snmpconfig
					getcontentcheck
					echo "- Encryption will be MD5 and DES"
					systemctl stop snmpd
					echo "- Deleting old SNMPv3 users in /usr/share/snmp/snmpd.conf"
					rm -f /usr/share/snmp/snmpd.conf
					echo "!! min 8 charachters password !!"
					net-snmp-config --create-snmpv3-user -ro -a MD5 -x DES
				else	
					clear
					echo "- Returning to menu - no valid choice selected"
					wait_or_input
					main_menu
				fi
			systemctl restart snmpd
			wait_or_input
			fi
		main_menu
	;;
	     8) clear;
		backup_menu

	   ;;
	   	 9) clear;
		mail_menu
        ;;

      0)
	  clear
      exit
      ;;
      esac
    fi
  done
  main_menu
}

mail_menu(){
			if [ $(dpkg-query -W -f='${Status}' libsasl2-modules 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
				  apt-get install -yqq libsasl2-modules;
			fi
			if [ $(dpkg-query -W -f='${Status}' mailutils 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
				  apt-get install -yqq mailutils;
			fi
			clear
			ALIASESBCK=/etc/aliases.BCK
			if test -f "$ALIASESBCK"; then
				echo "backup OK"
				else
				cp -n /etc/aliases /etc/aliases.BCK
			fi
			MAINCFBCK=/etc/postfix/main.cf.BCK
			if test -f "$MAINCFBCK"; then
				echo "backup OK"
				else
				cp -n /etc/postfix/main.cf /etc/postfix/main.cf.BCK
			fi
			clear
			NORMAL=`echo "\033[m"`
			MENU=`echo "\033[36m"` #Blue
			NUMBER=`echo "\033[33m"` #yellow
			FGRED=`echo "\033[41m"`
			RED_TEXT=`echo "\033[31m"`
			ENTER_LINE=`echo "\033[33m"`
			banner
			echo -e "${MENU}****************** Mail Menu (LEGACY) **********************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Configure ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Test ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Check logs for known errors - attempt to correct ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 4)${MENU} Restore original conf ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Back ${NORMAL}"
			echo " "
			echo -e "${MENU}*********************************************${NORMAL}"
			echo -e "${ENTER_LINE}Please enter a menu option number or ${RED_TEXT}enter to exit. ${NORMAL}"
			read -rsn1 opt
			while [ opt != '' ]
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			  case $opt in
			  1) clear;
					echo "- System administrator recipient mail address (user@domain.tld) (root alias): "
					read 'rootaddressalias'
					echo "- What is the mail server hostname? (smtp.gmail.com): "
					read 'mailserverhostname'
					echo "- What is the mail SMTP port? (Usually 587 - can be 25 (no tls)): "
					read 'smtpport'
					read -p  "- Does the server require TLS? y = yes / ANYTHING = no: " -n 1 -r 
					if [[ $REPLY =~ ^[Yy]$ ]]; then
					vartls=yes
					else
					vartls=no
					fi
					echo " "
					echo "- What is the AUTHENTIFICATION USERNAME? (user@domain.tld or username): "
					read 'authusername'
					echo "- What is the AUTHENTIFICATION PASSWORD?: "
					read 'authpassword'
					echo "- Is the SENDER mail address the same as the AUTHENTIFICATION USERNAME?"
					read -p " y to use $authusername / Enter to set something else: " -n 1 -r 
					if [[ $REPLY =~ ^[Yy]$ ]]; then
					senderaddress=$authusername
					else
					echo " "
					echo "- What is the sender email address?: "
					read 'senderaddress'
					fi
					echo " "
				echo "- Working on it!"
				echo " "
				echo "- Setting Aliases"
				if grep "root:" /etc/aliases
					then
					echo "- Alias entry was found: editing for $rootaddressalias"
					sed -i "s/^root:.*$/root: $rootaddressalias/" /etc/aliases
				else
					echo "- No root alias found: Adding"
					echo "root: $rootaddressalias" >> /etc/aliases
				fi
				
				#Setting canonical file for sender - :
				echo "root $senderaddress" > /etc/postfix/canonical
				chmod 600 /etc/postfix/canonical
				
				# Preparing for password hash
				echo [$mailserverhostname]:$smtpport $authusername:$authpassword > /etc/postfix/sasl_passwd
				chmod 600 /etc/postfix/sasl_passwd 
				
				# Add mailserver in main.cf
				sed -i "/#/!s/\(relayhost[[:space:]]*=[[:space:]]*\)\(.*\)/\1"[$mailserverhostname]:"$smtpport""/"  /etc/postfix/main.cf
				
				# Checking TLS settings
				echo "- Setting correct TLS Settings: $vartls"
				postconf smtp_use_tls=$vartls
				
				# Checking for password hash entry
					if grep "smtp_sasl_password_maps" /etc/postfix/main.cf
					then
					echo "- Password hash already setted-up"
				else
					echo "- Adding password hash entry"
					postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
				fi
				#checking for certificate
				if grep "smtp_tls_CAfile" /etc/postfix/main.cf
					then
					echo "- TLS CA File looks setted-up"
					else
					postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
				fi
				# Adding sasl security options
				# eliminates default security options which are imcompatible with gmail
				if grep "smtp_sasl_security_options" /etc/postfix/main.cf
					then
					echo "- Google smtp_sasl_security_options setted-up"
					else
					postconf smtp_sasl_security_options=noanonymous
				fi
				if grep "smtp_sasl_auth_enable" /etc/postfix/main.cf
					then
					echo "- Authentification already enabled"
					else
					postconf smtp_sasl_auth_enable=yes
				fi 
				if grep "sender_canonical_maps" /etc/postfix/main.cf
					then
					echo "- Canonical entry already existing"
					else
					postconf sender_canonical_maps=hash:/etc/postfix/canonical
				fi
    				if grep "smtp_header_checks" /etc/postfix/main.cf
					then
					echo "- smtp_header_checks entry already existing"
					else
					postconf -e 'smtp_header_checks = regexp:/etc/postfix/header_checks'
     					echo "/^From:(.*)/ REPLACE From: $hostname <$senderaddress>" > /etc/postfix/header_checks
				fi
				echo "- Encrypting password and canonical entry"
				postmap /etc/postfix/sasl_passwd
				postmap /etc/postfix/canonical
   				postmap /etc/postfix/header_checks
				echo "- Restarting postfix and enable automatic startup"
				systemctl restart postfix && systemctl enable postfix
				echo "- Cleaning file used to generate password hash"
				rm -rf "/etc/postfix/sasl_passwd"
				echo "- Files cleaned"
				wait_or_input
			  mail_menu;
      ;;

     2) clear;
		echo "- What is the recipient email address? :"
		read vardestaddress
		echo "- An email will be sent to: $vardestaddress"
		echo “If you receive this, it means your email configurations looks correct. Yay!” | mail -s "test mail - $hostname - $date" $vardestaddress
		echo "- Email should have been sent - If none received, you may want to check for errors in menu 3"
		wait_or_input
	  
	  mail_menu;	
      ;;
	        3) clear;
			echo "- Checking for known errors that may be found in logs"
			if grep "SMTPUTF8 is required" "/var/log/mail.log"
			then
			echo "- Errors im log found - SMTPUTF8 is required"
					if grep "smtputf8_enable = no" /etc/postfix/main.cf
						then
						echo "- Fix looks already applied!"
					else
						echo " "
						echo "- Setting "smtputf8_enable=no" to correct "SMTPUTF8 was required but not supported""
						postconf smtputf8_enable=no
						postfix reload
				 	 fi 

			elif grep "Network is unreachable" "/var/log/mail.log"; then
				read -p "- Are you on IPv4 AND your host can resolve and access public adresses? y = yes / anything = no: " -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]; then
					if grep "inet_protocols = ipv4" /etc/postfix/main.cf
					then
						echo "- Fix looks already applied!"
					else
						echo " "
						echo "- Setting "inet_protocols = ipv4 " to correct ""Network is unreachable" caused by ipv6 resolution""
						postconf inet_protocols=ipv4
						postfix reload
					fi
				fi
			elif grep "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then		
				echo "- Errors im log found - smtp_tls_security_level = encrypt is required"
				if grep "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
					echo "- Fix looks already applied!"
				else
					echo " "
					echo "- Setting "smtp_tls_security_level = encrypt" to correct"
					postconf inet_protocols=ipv4
					postfix reload
				fi
			elif grep "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then		
				echo "- Errors im log found - smtp_tls_wrappermode = yes is required"
				if grep "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
					echo "- Fix looks already applied!"
				else
					echo " "
					echo "- Setting "smtp_tls_wrappermode = yes" to correct"
					postconf smtp_tls_wrappermode=yes
					postfix reload
				fi
		    else
			echo "- No configured error found - nothing to do!"
			wait_or_input
			fi
	  mail_menu;	
      ;;
      4) clear;
		read -p "- Do you really want to restore? y = yes / anything = no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
					echo " "
					echo "- Restoring default configuration files"
				        cp -rf /etc/aliases.BCK /etc/aliases
					cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
					echo "- Restarting services "
					systemctl restart postfix
					echo "- Restoration done"
     					wait_or_input
			fi
	  mail_menu;
	     ;;

      0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
      ;;
      esac
    fi
  done
}

backup_menu(){
			clear
			NORMAL=`echo "\033[m"`
			MENU=`echo "\033[36m"` #Blue
			NUMBER=`echo "\033[33m"` #yellow
			FGRED=`echo "\033[41m"`
			RED_TEXT=`echo "\033[31m"`
			ENTER_LINE=`echo "\033[33m"`
			banner
			echo -e "${MENU}************ Backup and restoration Menu ****************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Backup configuration ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Restore configuration ${NORMAL}"
   			echo -e "${MENU}**${NUMBER} 3)${MENU} Restore a Self signed certificate ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Back ${NORMAL}"
			echo " "
			echo -e "${MENU}*********************************************${NORMAL}"
			echo -e "${ENTER_LINE}Please enter a menu option number or ${RED_TEXT}enter to exit. ${NORMAL}"
			read -rsn1 opt
			while [ opt != '' ]
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			case $opt in
			  1) clear;
			  backup
			  wait_or_input
			  clear
			  backup_menu
			;;
			2) clear;
			unset options i
			while IFS= read -r -d $'\0' f; do
			options[i++]="$f"
			done < <(find $backupdir -maxdepth 1 -type f -name "*.tar.gz" -print0 )
			select opt in "${options[@]}" "- Return to backup menu"; do
			  case "$opt" in 
			  *.tar.gz)
				  echo "- Backup archive $opt selected"
				  read -p "-- Proceed with the restoration?  y = yes / anything = no: " -n 1 -r
				  if [[ $REPLY =~ ^[Yy]$ ]]; then
				  	 echo " "
				  	 read -p "- Do you want to restore the network configuration aswell? y = yes / anything = no: " -n 1 -r
				  	 if [[ $REPLY =~ ^[Yy]$ ]]; then
					 	tar -xf "$opt" -C /

					 else
						tar -xf "$opt" --exclude='/etc/network/interfaces' -C /
					 fi
					 clear
					 echo "- File restauration done"
					 echo "- Installing missing dependencies if missing"
					 if [ -d "/etc/snmp/" ]; then
						echo "-- snmp config found - installing snmpd"
						apt-get -yqq install snmpd libsnmp-dev
					 fi
					 # Here we check in archive if fail2ban is existing in order to be able to rollback
					 if echo "$archivecontent" | grep -qi fail2ban; then
						echo "-- fail2ban config found - installing fail2ban"
						apt-get -yqq install fail2ban
					 else
					 	echo "-- fail2ban config NOT found - uninstalling fail2ban"
						apt-get -yqq remove --purge fail2ban
					 fi
					 echo "- Remounting previously existing storages if any"
					 if find /etc/systemd/system/*.mount; then
						echo "-- .mount file found - trying to remount"
						for mount in /etc/systemd/system/*.mount; do
							source $mount >/dev/null 2>&1
							echo "-- Checking if $mount is still present in system"
							if find /dev/disk/by-uuid/ | grep -w $What; then
							echo "-- Remountig using configuration $mount"
							mkdir -p "$Where" 
							echo "$What $Where $Type $Options 0 2" >> /etc/fstab 
							else
							echo "-- The drive for $mount was not found and will not be mounted back"
							fi
						done
						mount -a
					else
					echo "- No .mount file found"
					fi
					for pool in $(zpool import | grep pool: | awk '{print $2}'); do
						echo "- Importing pool $pool"
						zpool import -f $pool
					done
     					wait_or_input
					 read -p "- Do you want to reboot host now? y = yes / anything = no: " -n 1 -r
					if [[ $REPLY =~ ^[Yy]$ ]]; then
						reboot now
					else
						main_menu
					fi
				  else
					clear
					backup_menu
				  fi
				  ;;
				"- Return to backup menu")
				 backup_menu
				  ;;
				*)
				  echo "- Please choose using an number"
				  ;;
			  esac
			done
			;;
   			  3) clear;
			  echo "- Removing old certificates "
     			  rm -f /etc/pve/pve-root-ca.pem
	 		  rm -f /etc/pve/priv/pve-root-ca.key
   			  rm -f /etc/pve/nodes/$hostname/pve-ssl.pem
 			  rm -f /etc/pve/nodes/$hostname/pve-ssl.key
       			  echo "- Generating new certificates"
      			  pvecm updatecerts -f
			  wait_or_input
			  clear
			  backup_menu
			;;
      0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
      ;;
      esac
    fi
  done
}

main_menu
