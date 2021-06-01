#!/bin/bash

# Tonton Jo - 2020
# Join me on Youtube: https://www.youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw

# Script for easy setup of Proxomox email settings.
# Tested working with gmail and infomaniak mail servers using TLS

# DISCLAIMER
# I assume you know what you are doing have a backup and have a default configuration.
# I'm responsible in no way if something get broken - even if there's likely no chance to happen:-)
# I am no programmer - just tying to get some begginers life a bit easier
# There will be bugs or things i did not thinked about - sorry - if so, try to solve-it yourself, let me kindly know and PR:-)

# USAGE
# You can run this scritp directly using:
# wget https://raw.githubusercontent.com/Tontonjo/proxmox/master/ez_proxmox_mail_configurator.sh


varversion=1.0
#V1.0: Initial Release - proof of concept


# -----------------ENVIRONNEMENT VARIABLES----------------------
pve_log_folder="/var/log/pve/tasks/"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
# ---------------END OF ENVIRONNEMENT VARIABLES-----------------

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=5
BACKTITLE="Tonton Jo - 2021 - https://www.youtube.com/c/tontonjo"
TITLE="Proxmox Toolbox"
MENU="Choose one of the following options: "

OPTIONS=(1 "Install usefull libraries"
         2 "Hide enterprise sources"
         3 "Mail configurator"
         4 "Restore original conf"
         0 "Exit")
      while [ "$CHOICE -ne 4" ]; do
CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
	case $CHOICE in
      1)
			read -p "This will install thoses libraries if missing: libsasl2-modules ifupdown2 fail2ban. Press y to install" -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				if [ $(dpkg-query -W -f='${Status}' libsasl2-modules 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y libsasl2-modules;
				else
					echo "- libsasl2-modules already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' ifupdown2 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y ifupdown2;
				else
					echo "- ifupdown2 already installed"
				fi
				if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
					apt-get install -y fail2ban;
				else
					echo "- fail2ban already installed"
				fi
			fi
      ;;

     2)
		if [ -d "$pve_log_folder" ]; then
			echo "- Server is a PVE host"
			echo "- Checking Sources list"
			if grep -Fxq "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list; then
				echo "-- Source looks alredy configured - Skipping"
			else
				echo "-- Adding new entry to sources.list"
				sed -i "\$adeb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
			fi
			echo "- Checking Enterprise Source list"
			if grep -Fxq "#deb https://enterprise.proxmox.com/debian/pve $distribution pve-enterprise" /etc/apt/sources.list.d/pve-enterprise.list; then
				echo "-- Entreprise repo looks already commented - Skipping"
			else
				echo "-- Hiding Enterprise sources list"
				sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
			fi
		else
			echo "- Server is a PBS host"
			echo "- Checking Sources list"
			if grep -Fxq "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list; then
				echo "-- Source looks alredy configured - Skipping"
			else
				echo "-- Adding new entry to sources.list"
			sed -i "\$adeb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list
			fi
			echo "- Checking Enterprise Source list"
			if grep -Fxq "#deb https://enterprise.proxmox.com/debian/pbs $distribution pbs-enterprise" /etc/apt/sources.list.d/pbs-enterprise.list; then
				echo "-- Entreprise repo looks already commented - Skipping"
			else
				echo "-- Hiding Enterprise sources list"
				sed -i 's/^/#/' /etc/apt/sources.list.d/pbs-enterprise.list
				fi
		fi
      ;;
	        3)
			echo "- Checking for known errors that may be found in logs"
			if grep "SMTPUTF8 is required" "/var/log/mail.log"
			then
			echo "- Errors may have been found "
			read -p "Looks like there's a error as SMTPUTF8 was required but not supported: try to fix? y = yes / anything=no: " -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					if grep "smtputf8_enable = no" /etc/postfix/main.cf
					then
					echo "- Fix looks already applied!"
					else
					echo " "
					echo "- Setting "smtputf8_enable=no" to correct "SMTPUTF8 was required but not supported""
					postconf smtputf8_enable=no
					postfix reload
				  fi 
				fi
		        else
			echo "- No configured error found - nothing to do!"
			fi	
      ;;
      4)
		read -p "Do you really want to restore: y=yes - Anything=no: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo " "
					echo "- Restoring default configuration files"
				        cp -rf /etc/aliases.BCK /etc/aliases
					cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
					echo "- Restarting services "
					systemctl restart postfix
					echo "- Restoration done"
			fi
	     ;;
      0)
      exit
      ;;
      esac
	  done
