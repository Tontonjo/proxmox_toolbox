# Proxmox Toolbox  
## Toolbox to setup Proxmox Virtual Environment and Backup Server

![image](https://github.com/Tontonjo/proxmox_toolbox/assets/60965766/dc7f1493-0d29-4a7a-b84e-f1e61dcc7ffc)


## Tonton Jo  
### Rejoint la trame - Join the community & Support my work   
[Click Here!](https://linktr.ee/tontonjo)  

## Informations:

This little tool aim to get smalls one-time configurations for Proxmox Virtual environement and backup server hosts in no time.  
It automatically will find if the host is a pve or a pbs host and setup accordingly.  

### Demonstration:  
You can watch a demonstration of the tool [in this playlist](https://www.youtube.com/playlist?list=PLU73OWQhDzsTpLpVNspJ14rVrXAmo2Biu) 

### Prerequisits:
- Up-to-date PVE 8 / 9 or PBS 3 / 4
- Internet connexion

## Features are:
- Automatic PVE / PBS host detection
- Hide enterprise repo and set no-subscription repository
-  -  when no-enterprise source is set, disable no-subscription message
- Update host and create a new command "proxmox-update"
- Install usefull dependencies: ifupdown2, git, sudo, libsasl2-modules, amd64-microcode (add non-free-firmware repository)
- Security settings:
- - Enable fail2ban with default configuration for sshd, Proxmox virtual environement and Proxmox backup server  
(credits to [inettgmbh](https://github.com/inettgmbh/fail2ban-proxmox-backup-server))  
- - Create another debian user with sudo rights
- - Disable root ssh login
- - Create another Proxmox GUI administrator (login with Proxmox VE Realm)
- - Disabling root@pam user !!! root@pam is needed to update from GUI - update can still be done trough SSH if disabled !!!
- SWAP value change or disable 
- Enable S.M.A.R.T self-tests on all supported drives
- - short: every sunday@22h - Long: every 1st of month @22h
- Enable SNMP V2 or v3
- Backup and restore Proxmox Virtual Environment and Backup Server configurations
- - Easy recover from crash or failure: restore VM configurations, datastores and host configurations like network and PVE users
- - Automatic remount of directories and zpools using previously existing configurations
- - Please find more informations below  

## Legacy hidden function:
- Configure email service to send system and proxmox notifications (postfix)

## News  
2023.11.24: Proxmox 8.1 - Emails Notifications - Proxmox VE now supports email configurations very well from the GUI, the toolbox wont get any update related to this function anymore.  

## Usage and arguments:
###  Download and execute:  
```shell
wget -qO proxmox_toolbox.sh https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh && bash proxmox_toolbox.sh
```
### OR just execute:
```shell
bash <(wget -qO- https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh)
```

### Updating host & remove subscription message
The script will update your host and detect if the no-enterprise source is configured, if so, remove the subscription message.
- If you still encounter it after, clear your broswer cache.
- If you update your host directly within the system, the no subscribtion message may reappear when the file gets updated.  
- In order to nerver see this again, you have to update Proxmox with one of the following options:

To start an update only, without menu or prompt:
```shell
bash proxmox_toolbox.sh -u
```
Once the tool has been used to update host, you can execute this command to fully update your host - kind of an alias of bash proxmox_toolbox.sh -u
```shell
proxmox-update
```

### Backup configuration  
To start a configuration backup only:
```shell
bash proxmox_toolbox.sh -b
```  
## Fail2ban:  
If you enable fail2ban, i guess you know what you're doing, if you dont: here's some usefull informations and commands:  
- ban are for 1 hour
- ssh and web interface logins are monitored  
#### List of $jailname:
```ssh
fail2ban-client status
```
#### get status of a jails - display banned IP's
```ssh
fail2ban-client status $jailname
```
#### Unband an IP:
```ssh
fail2ban-client set $jailname unbanip  $ipaddress
```


## Backup and Restoration:  
- Be carefull as this was not extensively tested - especially not with cluster configurations
- The following folders and configurations are backuped by default:  
```/etc/ssh/sshd_config /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/pve/ /etc/lvm/ /etc/modprobe.d/ /var/lib/pve-firewall/ /var/lib/pve-cluster/  /etc/vzdump.conf /etc/ksmtuned.conf /etc/proxmox-backup/```  

### Backup
The script will put every folder listed in backup_content in a tar.gz archive.  
- You cand add /remove folder trough the edit of backup_content= line in the script
- You can change the target folder to use for backup and restoration in the script env. variables at: backupdir="/root/"

Once the backup is done, a tar.gz archive is located at backupdir="/root/".  

### Restauration:  
The script looks for tar.gz files located in backupdir="/root/" and will list all the available archives for you to choose one.  
Warning: The restauration will overwrite any existing file with the one in archive  

The restauration process will:
- Reinstall missing dependencies for snmp and fail2ban if config were existing  
- Restore Proxmox configurations (proxmox configs, certificates, vm configs, storages configs, proxmox users)
- Automatically remount the following storages: dir and zpools

## Directory mountpoint and zpool

In case of need, here's how you can manually mount storages:

#### Directory:
Mount configurations are located in /etc/systemd/system/mnt-datastore-$datastorename.mount  
- run the following commands:  
```shell
source /etc/systemd/system/mnt-datastore-$datastorename.mount  
mkdir -p "$Where"
echo "$What $Where $Type $Options 0 2" >> /etc/fstab  
mount -a
```  
- Control if the drives are now correctly mounted  
- Add a new Directory storage in pve/pbs using "where" as directory path  
#### Zpool:  
- run 
```shell
zpool import
```  
- Take note of the "pool" name and run
```shell
zpool import -f $poolname
```  
- Add a new ZFS storage in pve/pbs  
## SOURCES:
https://pve.proxmox.com/wiki/Fail2ban  
https://github.com/inettgmbh/fail2ban-proxmox-backup-server  
https://forum.proxmox.com/threads/how-do-i-set-the-mail-server-to-be-used-in-proxmox.23669/  
https://linuxscriptshub.com/configure-smtp-with-gmail-using-postfix/  
https://suoption_pickedpport.google.com/accounts/answer/6010255  
https://www.howtoforge.com/community/threads/solved-problem-with-outgoing-mail-from-server.53920/  
http://mhawthorne.net/posts/2011-postfix-configuring-gmail-as-relay/  
https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/add-ssh-enabled-user.html  
https://www.noobunbox.net/serveur/monitoring/configurer-snmp-v3-sous-debian  
https://github.com/DeadlockState/Proxmox-prepare  
https://blog.lbdg.me/proxmox-best-performance-disable-swappiness/  
https://gist.github.com/mrpeardotnet/6bdc4b504f43ce57fa7eaee96d376edf  
https://github.com/DerDanilo/proxmox-stuff/blob/master/prox_config_backup.sh  
https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0  
https://wiki.debian.org/SSDOptimization  
https://www.linuxtricks.fr/wiki/proxmox-quelques-infos  
https://bobcares.com/blog/fail2ban-unban-ip/

## TODO:  
settings for zram -> https://pve.proxmox.com/wiki/Zram  
PBS: add support for user creation and backup / restoration
user creation fro PBS when available  
make things stupid-proof (deny characters when numbers expected and so on)  
