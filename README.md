# Proxmox Toolbox  
## Toolbox to setup Proxmox Virtual Environment and Backup Server

![screenshot](https://i.ibb.co/Tr3rbw0/Screenshot-2022-12-29-101432.png)  

## Tonton Jo  
### Join the community:
[![Youtube](https://badgen.net/badge/Youtube/Subscribe)](http://youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw?sub_confirmation=1)
[![Discord Tonton Jo](https://badgen.net/discord/members/h6UcpwfGuJ?label=Discord%20Tonton%20Jo%20&icon=discord)](https://discord.gg/h6UcpwfGuJ)
### Support my work, give a thanks and help the youtube channel:
[![Ko-Fi](https://badgen.net/badge/Buy%20me%20a%20Coffee/Link?icon=buymeacoffee)](https://ko-fi.com/tontonjo)
[![Infomaniak](https://badgen.net/badge/Infomaniak/Affiliated%20link?icon=K)](https://www.infomaniak.com/goto/fr/home?utm_term=6151f412daf35)
[![Express VPN](https://badgen.net/badge/Express%20VPN/Affiliated%20link?icon=K)](https://www.xvuslink.com/?a_fid=TontonJo)  
## Informations:

This little tool aim to get smalls one-time configurations for Proxmox Virtual environement and backup server hosts in no time.  
It automatically will find if the host is a pve or a pbs host and setup accordingly.  

### Demonstration:  
You can watch a demonstration of the tool [in this playlist](https://www.youtube.com/playlist?list=PLU73OWQhDzsTpLpVNspJ14rVrXAmo2Biu) 

### Prerequisits:
- Up-to-date PVE 7 / 8 or PBS server
- Internet connexion

## Features are:
- Automatic PVE / PBS host detection
- Hide enterprise repo and set no-subscription repository
- Update host and create a new command "proxmox-update"
-  -  when no-enterprise source is set, disable no-subscription message
- Install usefull dependencies: ifupdown2 - git - sudo - libsasl2-modules - snmp
- Security settings:
- - Enable fail 2 ban with default configuration for sshd, proxmox virtual environement and backup server  
(credits to [inettgmbh](https://github.com/inettgmbh/fail2ban-proxmox-backup-server))  
- - Create another debian user with sudo rights
- - Disable root ssh login
- - Create another Proxmox GUI administrator (login with Proxmox VE Realm)
- - Disabling root@pam user !!! root@pam is needed to update from GUI - update can still be done trough SSH if disabled !!!
- Change or disable SWAP 
- Enable S.M.A.R.T self-tests on all supported drives
- - short: every sunday@22 - Long: every 1st of month @22
- Enable SNMP V2 or v3 - you choose - with a default working configuration
- Configure email service to send system and proxmox notifications (postfix)
- Backup and restore Proxmox Virtual Environment and Backup Server configuration
- - Automatic remount of directories and zpools using previously existing configurations
- - Please find more informations below  

## USAGE
###  Get and execute:  
```shell
wget -qO proxmox_toolbox.sh https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh && bash proxmox_toolbox.sh
```

### Updating host & remove subscription
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
### Fail2ban:  
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
Mount configurations are located in /etc/systemd/system/*.mount  
- run the following commands with the values you just retreived
```shell
mkdir -p "$where"
echo "$what $where $Type $Options 0 2" >> /etc/fstab  
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

Tonton Jo - 2022
