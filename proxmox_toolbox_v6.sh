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
# Arguments: -u (update only) -b (backup only) -t (text menu instead of whiptail) -h (help)

# SOURCES:
# https://pve.proxmox.com/wiki/Fail2ban
# https://pve.proxmox.com/wiki/System_Software_Updates
# https://forum.proxmox.com/threads/how-do-i-set-the-mail-server-to-be-used-in-proxmox.23669/
# https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0

# https://www.linuxtricks.fr/wiki/proxmox-quelques-infos

# https://github.com/inettgmbh/fail2ban-proxmox-backup-server
# https://linuxscriptshub.com/configure-smtp-with-gmail-using-postfix/
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
version=6.1.1

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
# V5.3.1: Various corrections and enhancements
# V6.0.0: New whiptail interface (arrow keys menus, checklist, hidden password input) - text menu kept as fallback (-t or whiptail missing)
#         Menus are now loops instead of recursive calls - Security settings split in a sub-menu
#         Fix: restoration was always uninstalling fail2ban ($archivecontent was never set)
#         Fix: "AllowGroups sudo" was locking root out of SSH (and clusters) - now "AllowGroups root sudo" in sshd_config.d, validated with sshd -t
#         Fix: certificate regeneration now asks confirmation, is PVE only and keeps the cluster CA on cluster nodes
#         Fix: first-run backup called wait_or_input before it was defined and ignored $backupdir
#         Fix: SNMP menu left a useless git clone that made the fail2ban setup fail afterwards
#         Fix: update could loop forever when proxmox-update download failed
#         Fix: lm-sensors check typo, smartd not restarted, fstab duplicates on restore, endless pveum retries,
#              fail2ban "inactive" detected as active, wrong postfix fix for smtp_tls_security_level, backup reported done on failure
# V6.1.0: Menus can be used with numbers again (direct selection like the text menu) as well as arrows - hidden mail menu (9) reachable again
# V6.1.1: proxmox-update command 1.3: toolbox downloaded in a temporary file instead of piped to bash (apt / dpkg questions no longer read the script)

# check if root
if [[ $(id -u) -ne 0 ]] ; then echo "- Please run as root / sudo" ; exit 1 ; fi

# -----------------User variables----------------------
backupdir="/root/proxmox_config_backups" # NO trailing slash is mandatory
backup_content="/etc/ssh/sshd_config /etc/ssh/sshd_config.d/ /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/sysctl.d/ /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/pve/ /etc/lvm/ /etc/modprobe.d/ /var/lib/pve-firewall/ /var/lib/pve-cluster/ /etc/corosync/authkey /etc/vzdump.conf /etc/ksmtuned.conf /etc/proxmox-backup/"

# ----------------- System variables----------------------
updatebinversion=1.3
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/os-release;echo $VERSION_CODENAME)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)
repo_raw="https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main"
ssh_toolbox_conf="/etc/ssh/sshd_config.d/proxmox_toolbox.conf"

# Text menu colors
NORMAL="\033[m"
MENU="\033[36m"       # Blue
NUMBER="\033[33m"     # Yellow
RED_TEXT="\033[31m"
ENTER_LINE="\033[33m"
# ---------------END OF VARIABLES-----------------

is_pve() { [ -d "$pve_log_folder" ]; }

if is_pve; then
	host_type="PVE"
	host_version=$(pveversion 2>/dev/null | cut -d'/' -f2)
else
	host_type="PBS"
	host_version=$(proxmox-backup-manager version 2>/dev/null | awk '{print $2}')
fi

# ================= Interface: whiptail with text fallback =================
use_gui=0
backtitle="Proxmox Toolbox $version - Tonton Jo - $host_type $host_version - $hostname"
# Theme using the original toolbox colors: cyan menus and yellow highlights
export NEWT_COLORS='
root=cyan,black
roottext=cyan,black
window=white,black
border=cyan,black
shadow=,black
title=yellow,black
textbox=white,black
listbox=white,black
actlistbox=black,cyan
actsellistbox=black,cyan
sellistbox=yellow,black
checkbox=white,black
actcheckbox=black,cyan
entry=white,black
button=black,cyan
actbutton=black,yellow
compactbutton=white,black
'

# Dialog size adapted to the terminal (h / w)
ui_dims() {
	local lines=24 cols=80
	read -r lines cols < <(stty size </dev/tty 2>/dev/null) || true
	h=$(( lines < 26 ? lines - 2 : 24 ))
	w=$(( cols < 84 ? cols - 4 : 80 ))
}

# Height needed to display a text in a dialog (wrapped lines + borders and buttons), capped to the terminal
ui_text_height() {
	local line total=0
	while IFS= read -r line; do
		total=$(( total + ${#line} / (w - 6) + 1 ))
	done <<< "$1"
	total=$(( total + ${2:-6} ))
	echo $(( total < h ? total : h ))
}

# Display the banner in text menu
banner() {
	echo -e "${MENU}****************** Proxmox Toolbox **********************${NORMAL}"
	echo -e "${MENU}*********** Tonton Jo - 2025 - Version $version ************${NORMAL}"
	echo -e "${MENU}********** https://www.youtube.com/c/tontonjo **********${NORMAL}"
	echo -e "${MENU} ${NORMAL}"
}

# ---------- Menu drawn in bash, same look as whiptail ----------
# whiptail menus can only be used with arrows: this one also selects an entry directly with its number
menu_bg="\033[0;37;40m"      # white on black
menu_border="\033[0;36;40m"  # cyan
menu_title="\033[1;33;40m"   # yellow
menu_tag="\033[0;33;40m"     # yellow numbers, like the text menu
menu_selected="\033[0;30;46m" # black on cyan
if [[ $(locale charmap 2>/dev/null) == "UTF-8" ]]; then
	box_h='─' box_v='│' box_tl='┌' box_tr='┐' box_bl='└' box_br='┘' key_updown='↑↓'
else
	box_h='-' box_v='|' box_tl='+' box_tr='+' box_bl='+' box_br='+' key_updown='Up/Down'
fi

# Repeat a string: repeat "string" count
repeat() {
	local spaces
	printf -v spaces '%*s' "$2" ''
	printf '%s' "${spaces// /$1}"
}

# Keys: arrows + Enter, number = direct selection, Esc / q = back
# ui_hidden="9" allows a hidden entry to be selected with its key (legacy mail menu)
ui_menu_gui() {
	local title=$1 text=$2 tags=() labels=() key rest i matches first result="" status=1
	shift 2
	while (( $# )); do tags+=("$1"); labels+=("$2"); shift 2; done
	local count=${#tags[@]} sel=0 top=0 lines=24 cols=80
	read -r lines cols < <(stty size </dev/tty 2>/dev/null) || true
	local width=$(( cols < 84 ? cols - 4 : 80 ))
	local inner=$(( width - 2 ))
	local rows=$(( count < lines - 9 ? count : lines - 9 ))
	local y=$(( (lines - rows - 6) / 2 + 1 )) x=$(( (cols - width) / 2 + 1 ))
	local label_width=$(( inner - 7 ))
	local hint=" $key_updown or number: choose - Enter: select - Esc: ${cancel_label:-Back} "

	# Box line: row, content already padded to the inner width
	box_line() { printf '\033[%d;%dH%b%s%b%b%b%s' "$1" "$x" "$menu_border" "$box_v" "$menu_bg" "$2" "$menu_border" "$box_v"; }

	draw() {
		local row=$y idx title_left
		title_left=$(( (inner - ${#title} - 2) / 2 ))
		printf '\033[%d;%dH%b%s%b %s %b%s' "$row" "$x" "$menu_border" "$box_tl$(repeat "$box_h" "$title_left")" \
			"$menu_title" "$title" "$menu_border" "$(repeat "$box_h" $(( inner - title_left - ${#title} - 2 )))$box_tr"
		box_line $(( ++row )) "$(printf ' %-*.*s' $(( inner - 1 )) $(( inner - 1 )) "$text")"
		box_line $(( ++row )) "$(repeat ' ' "$inner")"
		for (( idx = top; idx < top + rows; idx++ )); do
			(( ++row ))
			if (( idx == sel )); then
				printf '\033[%d;%dH%b%s%b  %-3s %-*.*s %b%s' "$row" "$x" "$menu_border" "$box_v" "$menu_selected" \
					"${tags[idx]}" "$label_width" "$label_width" "${labels[idx]}" "$menu_border" "$box_v"
			else
				printf '\033[%d;%dH%b%s%b  %-3s %b%-*.*s %b%s' "$row" "$x" "$menu_border" "$box_v" "$menu_tag" \
					"${tags[idx]}" "$menu_bg" "$label_width" "$label_width" "${labels[idx]}" "$menu_border" "$box_v"
			fi
		done
		box_line $(( ++row )) "$(repeat ' ' "$inner")"
		# padding done by hand: printf counts bytes, not characters (arrows in UTF-8)
		local hint_left=$(( (inner - ${#hint}) / 2 ))
		box_line $(( ++row )) "$menu_border$(repeat ' ' "$hint_left")$hint$(repeat ' ' $(( inner - hint_left - ${#hint} )))"
		printf '\033[%d;%dH%b%s' $(( ++row )) "$x" "$menu_border" "$box_bl$(repeat "$box_h" "$inner")$box_br"
	}

	{
		printf '\033[?25l%b\033[2J\033[1;3H%b%s' "$menu_bg" "$menu_border" "$backtitle"
		while true; do
			draw
			IFS= read -rsn1 key </dev/tty
			case $key in
				$'\e')
					read -rsn2 -t 0.05 rest </dev/tty
					case $rest in
						'[A'|'OA') (( sel > 0 )) && (( sel-- )) ;;
						'[B'|'OB') (( sel < count - 1 )) && (( sel++ )) ;;
						'') break ;;   # Esc alone: back
					esac
					;;
				'') result=${tags[sel]}; status=0; break ;;   # Enter
				q|Q) break ;;
				*)
					# Number: select directly when only one entry matches, else move on the first match (lists > 9 entries)
					matches=0 first=-1
					for i in "${!tags[@]}"; do
						if [[ ${tags[i]} == "$key"* ]]; then
							(( first < 0 )) && first=$i
							(( matches++ ))
						fi
					done
					if (( matches == 1 )) && [[ ${tags[first]} == "$key" ]]; then
						result=$key; status=0; break
					elif (( first >= 0 )); then
						sel=$first
					elif [[ " ${ui_hidden:-} " == *" $key "* ]]; then
						result=$key; status=0; break
					fi
					;;
			esac
			# Scroll when the list is higher than the screen
			(( sel < top )) && top=$sel
			(( sel >= top + rows )) && top=$(( sel - rows + 1 ))
		done
		printf '\033[0m\033[?25h\033[2J\033[H'
	} >&2
	echo "$result"
	return $status
}

# Menu: ui_menu "title" "text" tag item [tag item...] -> prints the chosen tag (empty = back / exit)
# Set cancel_label=Exit before the call to rename the cancel button
ui_menu() {
	local title=$1 text=$2 count opt
	shift 2
	if (( use_gui )); then
		ui_menu_gui "$title" "$text" "$@"
		return
	fi
	count=$(( $# / 2 ))
	{
		clear
		banner
		echo -e "${MENU}****************** $title **********************${NORMAL}"
		echo " "
		while (( $# )); do
			echo -e "${MENU}**${NUMBER} $1)${MENU} $2 ${NORMAL}"
			shift 2
		done
		echo " "
		echo -e "${MENU}*********************************************${NORMAL}"
		echo -e "${ENTER_LINE}$text - ${RED_TEXT}enter to go back / exit ${NORMAL}"
	} >&2
	# more than 9 entries (backup archives list): read a full line instead of a single key
	if (( count > 9 )); then read -r opt; else read -rsn1 opt; fi
	echo "$opt"
}

# Yes / No question: ui_yesno "question" [no] -> returns 0 for yes. "no" makes No the default answer
ui_yesno() {
	if (( use_gui )); then
		ui_dims
		whiptail --backtitle "$backtitle" --title " Confirmation " ${2:+--defaultno} --yesno "$1" "$(ui_text_height "$1")" "$w"
		return
	fi
	read -p "$1 y = yes / ANYTHING = no: " -n 1 -r
	echo " "
	[[ $REPLY =~ ^[Yy]$ ]]
}

# Text input: ui_input "prompt" [default] -> prints the value, returns 1 if cancelled
ui_input() {
	if (( use_gui )); then
		ui_dims
		whiptail --backtitle "$backtitle" --title " Input " --inputbox "$1" 10 "$w" "$2" 3>&1 1>&2 2>&3
		return
	fi
	local value
	read -rp "- $1 ${2:+[$2] }" value
	echo "${value:-$2}"
}

# Hidden input: ui_password "prompt" -> prints the value, returns 1 if cancelled
ui_password() {
	if (( use_gui )); then
		ui_dims
		whiptail --backtitle "$backtitle" --title " Password " --passwordbox "$1" 10 "$w" 3>&1 1>&2 2>&3
		return
	fi
	local value
	read -rsp "- $1 " value
	echo " " >&2
	echo "$value"
}

# Message: ui_msg "text"
ui_msg() {
	if (( use_gui )); then
		ui_dims
		whiptail --backtitle "$backtitle" --title " Proxmox Toolbox " --msgbox "$1" "$(ui_text_height "$1")" "$w"
		return
	fi
	echo -e "$1"
	wait_or_input
}

# Checklist: ui_checklist "title" "text" tag item ON|OFF [...] -> prints selected tags, one per line
# Text mode: selects the ON entries after a confirmation
ui_checklist() {
	local title=$1 text=$2 selected=()
	shift 2
	if (( use_gui )); then
		ui_dims
		local list=$(( $# / 3 ))
		(( list > h - 8 )) && list=$(( h - 8 ))
		whiptail --backtitle "$backtitle" --title " $title " --separate-output \
			--checklist "$text" $(( list + 8 )) "$w" "$list" "$@" 3>&1 1>&2 2>&3
		return
	fi
	while (( $# )); do
		[[ $3 == "ON" ]] && selected+=("$1")
		shift 3
	done
	ui_yesno "- $text ${selected[*]} - Continue?" || return 1
	printf '%s\n' "${selected[@]}"
}

# Function to wait an amount of time or a key press - used after commands outputs
wait_or_input() {
	local timeout=30 # timeout
	local input
	if read -t "$timeout" -n 1 -p "- Continue: press any key or wait $timeout seconds... " input; then
		echo "Key pressed: continuing"
	else
		echo "- No key pressed until $timeout timeout. continuing..."
	fi
}

# ================= Helpers =================
# Validate that a content retreiving was successfull - usage: command; getcontentcheck || return
getcontentcheck() {
	local exitcode=$?
	if [ $exitcode -ne 0 ]; then
		echo "- Error retreiving ressources - control your internet connexion"
		wait_or_input
		return 1
	fi
}

# Install a package only if missing
install_if_missing() {
	if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"; then
		echo "- $1 already installed"
	else
		apt-get install -y "$1"
	fi
}

# Run a command up to 3 times
retry() {
	local attempt
	for attempt in 1 2 3; do
		"$@" && return 0
		echo "  -> Failed (attempt $attempt/3)"
		sleep 1
	done
	return 1
}

# ================= Features =================
# backup the configurations - optional $1: archive name without extension
backup() {
	local archive="$backupdir/${1:-$hostname-$(date +%Y_%m_%d-%H_%M_%S)}.tar.gz"
	local paths=() path
	# Only keep existing paths (globs like /etc/cron* are expanded here) to avoid tar errors
	for path in $backup_content; do
		[ -e "$path" ] && paths+=("$path")
	done
	mkdir -p "$backupdir"
	echo "- Creating backup"
	if tar -czf "$archive" --absolute-names "${paths[@]}"; then
		echo "-- Backup done at $archive - please control and test it"
	else
		echo "!! Backup finished with errors - please control $archive"
	fi
}

remove_subscription_message() {
	# Check if the js file is already modified to bypass no subscription message (need to match old erroneous == )
	if grep -q "res\.data\.status\.toLowerCase() *==\{0,2\} *'active'" $proxmoxlib; then
		echo "- Subscription Message already removed - Skipping"
	elif is_pve; then
		echo "- Removing No Valid Subscription Message for PVE"
		sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart pveproxy.service
	else
		echo "- Removing No Valid Subscription Message for PBS"
		sed -Ezi.bak "s/!== 'active'/=== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart proxmox-backup-proxy.service
	fi
}

# Update
update() {
	# Check if the /usr/bin/proxmox-update entry for update is already created
	if ! grep -Fqs "$updatebinversion" /usr/bin/proxmox-update; then
		echo "- Downloading / Updating update binary to version $updatebinversion"
		if wget -qO /usr/bin/proxmox-update.tmp "$repo_raw/bin/proxmox-update"; then
			mv -f /usr/bin/proxmox-update.tmp /usr/bin/proxmox-update && chmod +x /usr/bin/proxmox-update
		else
			rm -f /usr/bin/proxmox-update.tmp
			echo "- Could not download proxmox-update command - continuing with the update"
		fi
	fi
	echo "- Updating System using proxmox_toolbox.sh version $version"
	apt-get update -y -qq
	apt-get dist-upgrade -y -qq
	# We check for new source files first in case the sources arent modernized, then the old sources list entries
	if [[ -f /etc/apt/sources.list.d/proxmox.sources ]] || grep -Ewqis "no-subscription" /etc/apt/sources.list; then
		remove_subscription_message
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
	# --- Disable Enterprise ---
	if [[ -f /etc/apt/sources.list.d/pve-enterprise.sources ]]; then
		echo "-- Commenting PVE Enterprise repo (backup)"
		mv /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/pve-enterprise.sources.BAK
	fi
	# --- Disable Ceph Enterprise ---
	if [[ -f /etc/apt/sources.list.d/ceph.sources ]]; then
		echo "-- Comment Ceph enterprise repo (backup)"
		mv /etc/apt/sources.list.d/ceph.sources /etc/apt/sources.list.d/ceph.sources.BAK
	fi
	if grep -qs "^[[:space:]]*deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list; then
		echo "-- Found active Proxmox no subscription repo, commenting it..."
		sed -i "/^[[:space:]]*deb http:\/\/download\.proxmox\.com\/debian\/pve $distribution pve-no-subscription/ s/^/# /" /etc/apt/sources.list
		if ui_yesno "!! Looks like you upgraded your proxmox instance, it is recommanded to run \"apt modernize-sources\" !! execute?"; then
			apt modernize-sources
		fi
	fi
	if [[ -f /etc/apt/sources.list.d/pve-enterprise.list ]]; then
		echo "- Deleting old source list /etc/apt/sources.list.d/pve-enterprise.list"
		rm -f /etc/apt/sources.list.d/pve-enterprise.list
	fi
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
	if [[ ! -f /etc/apt/sources.list.d/pve-enterprise.list ]] || grep -Fq "#deb https://enterprise.proxmox.com/debian/pve" /etc/apt/sources.list.d/pve-enterprise.list; then
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

	if grep -qs '^[[:space:]]*deb http://download.proxmox.com/debian/pbs' /etc/apt/sources.list; then
		echo "-- Found active Proxmox Backup no-subscription repo in sources.list, commenting it..."
		sed -i '/^[[:space:]]*deb http:\/\/download\.proxmox\.com\/debian\/pbs/ s/^/# /' /etc/apt/sources.list
		if ui_yesno "!! Looks like you upgraded your proxmox instance, it is recommanded to run \"apt modernize-sources\" !! execute?"; then
			apt modernize-sources
		fi
	fi

	# --- Delete old list files ---
	if [[ -f /etc/apt/sources.list.d/pbs-enterprise.list ]]; then
		echo "- Deleting old source list /etc/apt/sources.list.d/pbs-enterprise.list"
		rm -f /etc/apt/sources.list.d/pbs-enterprise.list
	fi
	apt-get update -qq
else
	echo "- Configuring No-Subscription for Proxmox Backup Server $pbs_version"
	if grep -Fqs "deb http://download.proxmox.com/debian/pbs" /etc/apt/sources.list; then
		echo "-- PBS source already configured - Skipping"
	elif [ -f "/etc/apt/sources.list" ]; then
		echo "-- Adding PBS entry to sources.list"
		sed -i "\$adeb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list || \
			echo "-- sources.list appears to exist but an error was encountered. Please report this case on GitHub."
	else
		echo "-- sources.list seems to be missing: creating it in /etc/apt/sources.list"
		echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list
		wget -q https://enterprise.proxmox.com/debian/proxmox-release-$distribution.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-$distribution.gpg
	fi

	echo "- Checking PBS Enterprise Source list"
	if [[ ! -f /etc/apt/sources.list.d/pbs-enterprise.list ]] || grep -Fq "#deb https://enterprise.proxmox.com/debian/pbs" /etc/apt/sources.list.d/pbs-enterprise.list; then
		echo "-- PBS Enterprise repo looks already commented - Skipping"
	else
		echo "-- Hiding PBS Enterprise sources list"
		sed -i 's/^/#/' /etc/apt/sources.list.d/pbs-enterprise.list
	fi
fi
}

# ---------- Menu 1: sources ----------
menu_sources() {
	ui_yesno "This will configure sources for no-enterprise repository - Continue?" || return
	clear
	if is_pve; then
		proxmox_version=${host_version%%.*}
		sources_conf_pve
	else
		pbs_version=${host_version%%.*}
		sources_conf_pbs
	fi
	wait_or_input
}

# ---------- Menu 3: dependencies ----------
menu_dependencies() {
	local packages package
	packages=$(ui_checklist "Usefull dependencies" "This will install thoses libraries if missing:" \
		ifupdown2        "Apply network changes without reboot" ON \
		git              "Git client" ON \
		sudo             "Run commands as administrator" ON \
		rsyslog          "Classic log files in /var/log" ON \
		lshw             "Hardware listing" ON \
		lm-sensors       "Temperature sensors" ON \
		s-tui       	 "System Monitoring" OFF \
		stress      	 "Stress system in s-tui" OFF \
		libsasl2-modules "SMTP authentication for notifications" OFF) || return
		
	clear
	echo "- Updating sources"
	apt-get update -y -qq
	for package in $packages; do
		install_if_missing "$package"
	done
	if ui_yesno "Install amd64-microcode? This will Enable non-free-firmware sources" no; then
		if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
			# Check if source is already configured
			if ! grep -q "non-free-firmware" /etc/apt/sources.list.d/debian.sources; then
				sed -i '0,/^Components: main contrib$/s//Components: main contrib non-free-firmware/' /etc/apt/sources.list.d/debian.sources
			fi
		elif [[ -f "/etc/apt/sources.list" ]]; then
			if ! grep -q "non-free-firmware" /etc/apt/sources.list; then
				sed -i '0,/main contrib/s/^\(.*main contrib\)\(.*\)$/\1 non-free-firmware\2/' /etc/apt/sources.list
			fi
		fi
		apt-get update
		apt-get install -y amd64-microcode
	fi
	wait_or_input
}

# ---------- Menu 4: security ----------
security_fail2ban() {
	ui_yesno "Do you want to enable fail2ban?

SSH and web interface logins will be monitored - bans are for 1 hour" || return
	clear
	local tmpdir
	echo "- Updating sources"
	apt-get update -y -qq
	install_if_missing fail2ban; getcontentcheck || return
	echo "- Ensuring Git is installed"
	install_if_missing git; getcontentcheck || return
	echo "- Retreiving fail2ban Proxmox jails from github"
	tmpdir=$(mktemp -d)
	git clone -q https://github.com/Tontonjo/proxmox_toolbox.git "$tmpdir"
	getcontentcheck || { rm -rf "$tmpdir"; return; }
	if is_pve; then
		echo "- Host is a PVE Host"
		cp -f "$tmpdir/pve/filter.d/proxmox-virtual-environement.conf" /etc/fail2ban/filter.d/proxmox-virtual-environement.conf
		cp -f "$tmpdir/pve/jail.d/proxmox-virtual-environement.conf" /etc/fail2ban/jail.d/proxmox-virtual-environement.conf
	else
		echo "- Host is a PBS Host"
		cp -f "$tmpdir/pbs/filter.d/proxmox-backup-server.conf" /etc/fail2ban/filter.d/proxmox-backup-server.conf
		cp -f "$tmpdir/pbs/jail.d/proxmox-backup-server.conf" /etc/fail2ban/jail.d/proxmox-backup-server.conf
	fi
	echo "- Cleaning git ressources"
	rm -rf "$tmpdir"
	# Adding the right backend to fail2ban sshd configuration
	if ! grep -Fqs "systemd" /etc/fail2ban/jail.d/defaults-debian.conf; then
		echo "- Backend missing in defaults-debian.conf"
		echo -e "\nbackend = systemd" >> /etc/fail2ban/jail.d/defaults-debian.conf
	else
		echo "- Backend already setted-up in defaults-debian.conf"
	fi
	echo "- Restarting fail2ban service"
	systemctl restart fail2ban.service
	if systemctl is-active --quiet fail2ban; then
		echo "- Fail2ban started correctly"
	else
		echo "- Fail2ban failed to start"
		systemctl status fail2ban --no-pager
	fi
	wait_or_input
}

security_ssh_user() {
	ui_yesno "Do you want to create another SSH user?

This will guide you to create another user, add it as a sudo user and allow sudo users to connect trough ssh" || return
	local username password password2 cluster_warning=""
	username=$(ui_input "What is the new debian user username?") || return
	if [[ ! $username =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
		ui_msg "- Invalid username \"$username\" - use lowercase letters, numbers, - and _"
		return
	fi
	if id "$username" &>/dev/null; then
		ui_msg "- User $username already exists - nothing to do"
		return
	fi
	password=$(ui_password "Password for $username:") || return
	password2=$(ui_password "Confirm the password:") || return
	if [[ -z $password || $password != "$password2" ]]; then
		ui_msg "- Passwords are empty or do not match - user not created"
		return
	fi
	clear
	install_if_missing sudo; getcontentcheck || return
	useradd -m -s /bin/bash "$username"
	echo "$username:$password" | chpasswd
	mkdir -p "/home/$username/.ssh/"
	ssh-keygen -t rsa -b 4096 -f "/home/$username/.ssh/id_rsa" -q -N ""
	cp "/home/$username/.ssh/id_rsa.pub" "/home/$username/.ssh/authorized_keys"
	chown -R "$username:$username" "/home/$username/.ssh/"
	echo "- New user $username created"
	echo "- Adding user to sudo users"
	adduser "$username" sudo

	# SSH settings go in a dedicated file, read before sshd_config (first value wins)
	mkdir -p /etc/ssh/sshd_config.d
	grep -q "^Include /etc/ssh/sshd_config.d/\*.conf" /etc/ssh/sshd_config || sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
	# Remove the line added by toolbox < 6.0 that was locking root out of SSH
	sed -i '/^AllowGroups sudo$/d' /etc/ssh/sshd_config
	# root stays allowed: it is needed by clusters and until root login is explicitly denied
	grep -qs "^AllowGroups" "$ssh_toolbox_conf" || echo "AllowGroups root sudo" >> "$ssh_toolbox_conf"

	[ -f /etc/pve/corosync.conf ] && cluster_warning=$'\n\n!! This host is part of a cluster: nodes communicate as root over SSH - denying root login WILL break the cluster !!'
	if ui_yesno "Do you want to deny root SSH login?$cluster_warning" no; then
		sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
		grep -qs "^PermitRootLogin" "$ssh_toolbox_conf" || echo "PermitRootLogin no" >> "$ssh_toolbox_conf"
	fi
	# Only restart SSH with a valid configuration to avoid any lock out
	if sshd -t; then
		systemctl restart ssh
		echo "- SSH configuration applied"
	else
		echo "!! Invalid SSH configuration - removing $ssh_toolbox_conf - SSH not restarted"
		rm -f "$ssh_toolbox_conf"
	fi
	wait_or_input
}

security_pve_admin() {
	if ! is_pve; then
		ui_msg "- Host is a PBS host - user management not implemented ATM"
		return
	fi
	ui_yesno "Do you want to create an alternate PVE admin user?

The user will login with the \"Proxmox VE authentication server\" Realm" || return
	local pveusername admingroup
	pveusername=$(ui_input "What is the new pve username?") || return
	if [[ ! $pveusername =~ ^[A-Za-z0-9._-]+$ ]]; then
		ui_msg "- Invalid username \"$pveusername\""
		return
	fi
	admingroup=$(ui_input "What is the new admin group name?" "admins") || return
	if [[ ! $admingroup =~ ^[A-Za-z0-9._-]+$ ]]; then
		ui_msg "- Invalid group name \"$admingroup\""
		return
	fi
	clear
	# Check if the user already exists
	if pveum user list | grep -q "$pveusername@pve "; then
		echo "  -> User $pveusername already exists, skipping."
	else
		echo "- Creating PVE user $pveusername"
		retry pveum user add "$pveusername@pve" || { echo "  -> Could not create user $pveusername"; wait_or_input; return; }
		echo "  -> User $pveusername created successfully."
	fi
	echo "- Setting password for $pveusername"
	retry pveum passwd "$pveusername@pve" || { echo "  -> Could not set password"; wait_or_input; return; }
	echo "  -> Password set successfully for $pveusername."
	echo " "
	# Check if the group already exists
	if pveum group list | grep -qw "$admingroup"; then
		echo "  -> Group $admingroup already exists, skipping."
	else
		pveum group add "$admingroup" -comment "System Administrators"
		echo "  -> Group $admingroup created successfully."
	fi
	echo "- Defining administrators right"
	# Check if the group already has the Administrator role on /
	if pveum acl list | grep -w "$admingroup" | grep -q "Administrator"; then
		echo "  -> $admingroup already has Administrator rights, skipping."
	else
		pveum acl modify / -group "$admingroup" -role Administrator
		echo "  -> Administrator rights assigned to $admingroup."
	fi
	echo "- adding $pveusername to $admingroup"
	pveum user modify "$pveusername@pve" -group "$admingroup"
	echo "- You should now be able to login on GUI with $pveusername@Proxmox VE authenticaton Realm"
	wait_or_input
	if ui_yesno "!! Warning - root@pam is required to update host from Proxmox web ui !!

Do you want to disable \"root@pam\"?" no; then
		if ui_yesno "Are you sure you want to disable root@pam?" no; then
			echo "- Removing root user from PVE"
			pveum user modify root@pam -enable 0
		fi
	fi
}

menu_security() {
	local choice
	while true; do
		choice=$(ui_menu "Security settings" "Please choose an option" \
			1 "Enable fail2ban (SSH and web interface)" \
			2 "Create another SSH user with sudo rights" \
			3 "Create an alternate PVE GUI administrator" \
			0 "Back")
		case $choice in
			1) security_fail2ban ;;
			2) security_ssh_user ;;
			3) security_pve_admin ;;
			*) return ;;
		esac
	done
}

# ---------- Menu 5: swap ----------
menu_swap() {
	local swapvalue newswapvalue
	if [ -z "$(swapon --show --noheadings)" ]; then
		ui_msg "- System has no swap - Nothing to do"
		return
	fi
	swapvalue=$(cat /proc/sys/vm/swappiness)
	ui_yesno "SWAP is actually set on $swapvalue
Recommanded value: 1 - The lower the value - the less SWAP will be used - 0 to use SWAP only when out of memory

Do you want to edit swappiness value?" || return
	newswapvalue=$(ui_input "What is the new swapiness value? 0 to 100" "1") || return
	if [[ ! $newswapvalue =~ ^[0-9]+$ ]] || (( newswapvalue > 100 )); then
		ui_msg "- Invalid value \"$newswapvalue\" - must be a number from 0 to 100"
		return
	fi
	clear
	echo "- Setting swapiness to $newswapvalue"
	sysctl vm.swappiness="$newswapvalue"
	echo "vm.swappiness=$newswapvalue" > /etc/sysctl.d/swappiness.conf
	echo "- Emptying swap - This may take some time"
	swapoff -a
	echo "- Re-enabling with a swapiness of: $newswapvalue"
	swapon -a
	wait_or_input
}

# ---------- Menu 6: S.M.A.R.T ----------
menu_smart() {
	ui_yesno "Do you want to enable short and long S.M.A.R.T self-tests?

Short smart test will occure every sunday at 22H and long smart tests every 1 of month at 22H" || return
	clear
	if grep -Ewqi "(S/../../7/22|L/../01/./22)" /etc/smartd.conf; then
		echo "- Self tests looks already configured"
	else
		cp /etc/smartd.conf /etc/smartd.conf.BCK
		echo "- Enabling short and long self-tests"
		echo "DEVICESCAN -d auto -n never -a -s (S/../../7/22|L/../01/./22) -m root -M exec /usr/share/smartmontools/smartd-runner" > "/etc/smartd.conf"
		echo "- Restarting smartd"
		systemctl restart smartmontools 2>/dev/null || systemctl restart smartd
	fi
	echo "- Short smart test will occure every sunday at 22H and long smart tests every 1 of month at 22H"
	wait_or_input
}

# ---------- Menu 7: SNMP ----------
menu_snmp() {
	ui_yesno "Install and configure SNMP?" || return
	local snmpversion rocommunity allowedsubnet
	snmpversion=$(ui_menu "SNMP settings" "Choose the SNMP version" \
		2 "SNMP v2 - community (ReadOnly)" \
		3 "SNMP v3 - user and password (ReadOnly)" \
		0 "Back")
	case $snmpversion in
		2)
			rocommunity=$(ui_input "Read only community name? (ex: ro_tontonjo)") || return
			[[ -z $rocommunity ]] && return
			allowedsubnet=$(ui_input "Allowed subnet? Empty for none (x.x.x.x/xx)") || return
			;;
		3) ;;
		*) return ;;
	esac
	clear
	apt-get update -y -qq
	install_if_missing snmpd; getcontentcheck || return
	install_if_missing libsnmp-dev; getcontentcheck || return
	cp -n /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.backup
	snmpconfig; getcontentcheck || return
	if [[ $snmpversion == 2 ]]; then
		echo "- Setting SNMP"
		echo "rocommunity $rocommunity $allowedsubnet" >> /etc/snmp/snmpd.conf
	else
		echo "- Encryption will be MD5 and DES"
		systemctl stop snmpd
		echo "- Deleting old SNMPv3 users in /usr/share/snmp/snmpd.conf"
		rm -f /usr/share/snmp/snmpd.conf
		echo "!! min 8 charachters password !!"
		net-snmp-config --create-snmpv3-user -ro -a MD5 -x DES
	fi
	systemctl restart snmpd
	wait_or_input
}

# ---------- Menu 8: backup and restoration ----------
restore() {
	local archives=() items=() i choice archive archivecontent mount found_mount=0
	local exclude=(--exclude='/etc/network/interfaces')
	mapfile -d '' archives < <(find "$backupdir" -maxdepth 1 -type f -name "*.tar.gz" -print0 2>/dev/null | sort -rz)
	if (( ${#archives[@]} == 0 )); then
		ui_msg "- No backup archive found in $backupdir"
		return
	fi
	for i in "${!archives[@]}"; do
		items+=("$(( i + 1 ))" "$(basename "${archives[$i]}")")
	done
	choice=$(ui_menu "Restore configuration" "Select the backup archive to restore" "${items[@]}") || return
	[[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#archives[@]} )) || return
	archive=${archives[$(( choice - 1 ))]}

	ui_yesno "Backup archive $(basename "$archive") selected

Warning: The restauration will overwrite any existing file with the one in archive

Proceed with the restoration?" no || return
	ui_yesno "Do you want to restore the network configuration aswell?" no && exclude=()
	clear
	archivecontent=$(tar -tzf "$archive")
	tar -xf "$archive" "${exclude[@]}" -C /
	echo "- File restauration done"
	echo "- Installing missing dependencies if missing"
	apt-get update -qq
	if grep -q "etc/snmp/snmpd.conf" <<< "$archivecontent"; then
		echo "-- snmp config found - installing snmpd"
		apt-get -yqq install snmpd libsnmp-dev
	fi
	# Here we check in archive if fail2ban is existing in order to be able to rollback
	if grep -q "etc/fail2ban/" <<< "$archivecontent"; then
		echo "-- fail2ban config found - installing fail2ban"
		apt-get -yqq install fail2ban
	else
		echo "-- fail2ban config NOT found - uninstalling fail2ban"
		apt-get -yqq remove --purge fail2ban
	fi
	echo "- Remounting previously existing storages if any"
	for mount in /etc/systemd/system/*.mount; do
		[ -f "$mount" ] || continue
		found_mount=1
		unset What Where Type Options
		source "$mount" >/dev/null 2>&1
		[[ -z $What || -z $Where ]] && continue
		echo "-- Checking if $mount is still present in system"
		if [ -e "$What" ]; then
			if grep -qs "[[:space:]]${Where}[[:space:]]" /etc/fstab; then
				echo "-- $Where already in /etc/fstab"
			else
				echo "-- Remountig using configuration $mount"
				mkdir -p "$Where"
				echo "$What $Where $Type $Options 0 2" >> /etc/fstab
			fi
		else
			echo "-- The drive for $mount was not found and will not be mounted back"
		fi
	done
	if (( found_mount )); then mount -a; else echo "- No .mount file found"; fi
	if command -v zpool >/dev/null; then
		for pool in $(zpool import 2>/dev/null | grep pool: | awk '{print $2}'); do
			echo "- Importing pool $pool"
			zpool import -f "$pool"
		done
	fi
	wait_or_input
	if ui_yesno "Do you want to reboot host now?" no; then
		reboot now
	fi
}

regenerate_certificate() {
	if ! is_pve; then
		ui_msg "- This function is only available on Proxmox VE hosts"
		return
	fi
	local cluster=0 message
	[ -f /etc/pve/corosync.conf ] && cluster=1
	if (( cluster )); then
		message="This host is part of a cluster: only the certificate of this node will be regenerated - the cluster CA is kept."
	else
		message="This will delete the actual WEBUI certificates (root CA and node certificate) and generate new self-signed ones."
	fi
	ui_yesno "$message
Custom certificates (pveproxy-ssl.pem / ACME) are not affected.

Continue?" no || return
	clear
	echo "- Removing old certificates "
	if (( ! cluster )); then
		rm -f /etc/pve/pve-root-ca.pem /etc/pve/priv/pve-root-ca.key
	fi
	rm -f "/etc/pve/nodes/$hostname/pve-ssl.pem" "/etc/pve/nodes/$hostname/pve-ssl.key"
	echo "- Generating new certificates"
	pvecm updatecerts -f
	echo "- Restarting proxy service"
	systemctl restart pveproxy.service
	wait_or_input
}

backup_menu() {
	local choice
	while true; do
		choice=$(ui_menu "Backup and restoration" "Please choose an option" \
			1 "Backup configuration" \
			2 "Restore configuration" \
			3 "Regenerate a Self signed certificate for WEBUI" \
			0 "Back")
		case $choice in
			1) clear; backup; wait_or_input ;;
			2) restore ;;
			3) regenerate_certificate ;;
			*) return ;;
		esac
	done
}

# ---------- Menu 9 (hidden, legacy): mail ----------
mail_configure() {
	local rootaddressalias mailserverhostname smtpport vartls=no authusername authpassword senderaddress
	rootaddressalias=$(ui_input "System administrator recipient mail address (user@domain.tld) (root alias):") || return
	mailserverhostname=$(ui_input "What is the mail server hostname?" "smtp.gmail.com") || return
	smtpport=$(ui_input "What is the mail SMTP port? (Usually 587 - can be 25 (no tls))" "587") || return
	ui_yesno "Does the server require TLS?" && vartls=yes
	authusername=$(ui_input "What is the AUTHENTIFICATION USERNAME? (user@domain.tld or username)") || return
	authpassword=$(ui_password "What is the AUTHENTIFICATION PASSWORD?") || return
	if ui_yesno "Is the SENDER mail address the same as the AUTHENTIFICATION USERNAME ($authusername)?"; then
		senderaddress=$authusername
	else
		senderaddress=$(ui_input "What is the sender email address?") || return
	fi
	clear
	echo "- Working on it!"
	echo " "
	echo "- Setting Aliases"
	if grep -q "root:" /etc/aliases; then
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
	echo "[$mailserverhostname]:$smtpport $authusername:$authpassword" > /etc/postfix/sasl_passwd
	chmod 600 /etc/postfix/sasl_passwd

	# Add mailserver in main.cf
	sed -i "/#/!s/\(relayhost[[:space:]]*=[[:space:]]*\)\(.*\)/\1"[$mailserverhostname]:"$smtpport""/"  /etc/postfix/main.cf

	# Checking TLS settings
	echo "- Setting correct TLS Settings: $vartls"
	postconf smtp_use_tls=$vartls

	# Checking for password hash entry
	if grep -q "smtp_sasl_password_maps" /etc/postfix/main.cf; then
		echo "- Password hash already setted-up"
	else
		echo "- Adding password hash entry"
		postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
	fi
	#checking for certificate
	if grep -q "smtp_tls_CAfile" /etc/postfix/main.cf; then
		echo "- TLS CA File looks setted-up"
	else
		postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
	fi
	# Adding sasl security options
	# eliminates default security options which are imcompatible with gmail
	if grep -q "smtp_sasl_security_options" /etc/postfix/main.cf; then
		echo "- Google smtp_sasl_security_options setted-up"
	else
		postconf smtp_sasl_security_options=noanonymous
	fi
	if grep -q "smtp_sasl_auth_enable" /etc/postfix/main.cf; then
		echo "- Authentification already enabled"
	else
		postconf smtp_sasl_auth_enable=yes
	fi
	if grep -q "sender_canonical_maps" /etc/postfix/main.cf; then
		echo "- Canonical entry already existing"
	else
		postconf sender_canonical_maps=hash:/etc/postfix/canonical
	fi
	if grep -q "smtp_header_checks" /etc/postfix/main.cf; then
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
}

mail_test() {
	local vardestaddress
	vardestaddress=$(ui_input "What is the recipient email address?") || return
	clear
	echo "- An email will be sent to: $vardestaddress"
	echo "If you receive this, it means your email configurations looks correct. Yay!" | mail -s "test mail - $hostname - $date" "$vardestaddress"
	echo "- Email should have been sent - If none received, you may want to check for errors in menu 3"
	wait_or_input
}

mail_fix_errors() {
	clear
	echo "- Checking for known errors that may be found in logs"
	if grep -q "SMTPUTF8 is required" "/var/log/mail.log"; then
		echo "- Errors im log found - SMTPUTF8 is required"
		if grep -q "smtputf8_enable = no" /etc/postfix/main.cf; then
			echo "- Fix looks already applied!"
		else
			echo "- Setting \"smtputf8_enable=no\" to correct \"SMTPUTF8 was required but not supported\""
			postconf smtputf8_enable=no
			postfix reload
		fi
	elif grep -q "Network is unreachable" "/var/log/mail.log"; then
		if ui_yesno "Are you on IPv4 AND your host can resolve and access public adresses?"; then
			if grep -q "inet_protocols = ipv4" /etc/postfix/main.cf; then
				echo "- Fix looks already applied!"
			else
				echo "- Setting \"inet_protocols = ipv4\" to correct \"Network is unreachable\" caused by ipv6 resolution"
				postconf inet_protocols=ipv4
				postfix reload
			fi
		fi
	elif grep -q "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then
		echo "- Errors im log found - smtp_tls_security_level = encrypt is required"
		if grep -q "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
			echo "- Fix looks already applied!"
		else
			echo "- Setting \"smtp_tls_security_level = encrypt\" to correct"
			postconf smtp_tls_security_level=encrypt
			postfix reload
		fi
	elif grep -q "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then
		echo "- Errors im log found - smtp_tls_wrappermode = yes is required"
		if grep -q "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
			echo "- Fix looks already applied!"
		else
			echo "- Setting \"smtp_tls_wrappermode = yes\" to correct"
			postconf smtp_tls_wrappermode=yes
			postfix reload
		fi
	else
		echo "- No configured error found - nothing to do!"
	fi
	wait_or_input
}

mail_restore() {
	ui_yesno "Do you really want to restore the original mail configuration?" no || return
	clear
	echo "- Restoring default configuration files"
	cp -rf /etc/aliases.BCK /etc/aliases
	cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
	echo "- Restarting services "
	systemctl restart postfix
	echo "- Restoration done"
	wait_or_input
}

mail_menu() {
	clear
	install_if_missing libsasl2-modules
	install_if_missing mailutils
	[ -f /etc/aliases.BCK ] || cp -n /etc/aliases /etc/aliases.BCK
	[ -f /etc/postfix/main.cf.BCK ] || cp -n /etc/postfix/main.cf /etc/postfix/main.cf.BCK
	local choice
	while true; do
		choice=$(ui_menu "Mail Menu (LEGACY)" "Please choose an option" \
			1 "Configure" \
			2 "Test" \
			3 "Check logs for known errors - attempt to correct" \
			4 "Restore original conf" \
			0 "Back")
		case $choice in
			1) mail_configure ;;
			2) mail_test ;;
			3) mail_fix_errors ;;
			4) mail_restore ;;
			*) return ;;
		esac
	done
}

# ---------- Main menu ----------
main_menu() {
	local choice
	while true; do
		choice=$(cancel_label="Exit" ui_hidden="9" ui_menu "Main menu" "Please enter a menu option number" \
			1 "No-subscription Sources Configuration" \
			2 "Update host & create proxmox-update command" \
			3 "Install usefull dependencies" \
			4 "Security settings (fail2ban - SSH user - GUI Administrator)" \
			5 "SWAP Settings" \
			6 "Enable S.M.A.R.T self-tests" \
			7 "SNMP settings" \
			8 "PVE / PBS Configurations backup and restoration" \
			0 "Exit")
		case $choice in
			1) menu_sources ;;
			2) clear; update; wait_or_input ;;
			3) menu_dependencies ;;
			4) menu_security ;;
			5) menu_swap ;;
			6) menu_smart ;;
			7) menu_snmp ;;
			8) backup_menu ;;
			9) mail_menu ;;   # hidden legacy function
			*) clear; exit 0 ;;
		esac
	done
}

# ================= Arguments =================
# Thoses are argument that directly trigger specific toolbox functions
case $1 in
	-h|--help)
		echo "Proxmox Toolbox $version - usage: bash proxmox_toolbox.sh [option]"
		echo "  (no option)  Interactive menu"
		echo "  -u           Update host and remove the subscription message, without menu"
		echo "  -b           Backup configurations, without menu"
		echo "  -t           Use the text menu instead of the whiptail interface"
		echo "  -h           Show this help"
		exit 0
		;;
esac

# whiptail interface when available on an interactive terminal
if [[ $1 != "-t" ]] && command -v whiptail >/dev/null 2>&1 && [ -t 0 ] && [ -t 1 ]; then
	use_gui=1
	# Always give the cursor and colors back, even on Ctrl+C
	trap 'printf "\033[0m\033[?25h" >&2' EXIT
	trap 'exit 130' INT
fi

if [ ! -f "$backupdir/$hostname-firstrun.tar.gz" ]; then
	echo "- Creating a backup at first run - dont delete it :-)"
	backup "$hostname-firstrun"
	if [[ -z $1 || $1 == "-t" ]]; then
		ui_msg "First run: a backup of the actual configurations has been created at:
$backupdir/$hostname-firstrun.tar.gz

Dont delete it :-)"
	fi
fi

if [[ $1 == "-u" ]]; then
	update
	exit
fi

if [[ $1 == "-b" ]]; then
	backup
	exit
fi
# End of arguments

main_menu
