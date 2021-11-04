# Proxmox Toolbox  
## Toolbox to setup Proxmox Virtual Environment and Backup Server

## Tonton Jo - 2021  
### Join the community:
[![Youtube channel](https://github-readme-youtube-stats.herokuapp.com/subscribers/index.php?id=UCnED3K6K5FDUp-x_8rwpsZw&key=AIzaSyA3ivqywNPQz0xFZBHfPDKzh1jFH5qGD_g)](http://youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw?sub_confirmation=1)
[![Discord Tonton Jo](https://badgen.net/discord/members/2NQskxZjfp?label=Discord%20Tonton%20Jo%20&icon=discord)](https://discord.gg/2NQskxZjfp)
### Support the channel with one of the following link:
[![Buymeacoffee](https://badgen.net/badge/Buy%20me%20a%20Coffee/Link?icon=buymeacoffee)](https://www.buymeacoffee.com/tontonjo)
[![Infomaniak](https://badgen.net/badge/Infomaniak/Affiliated%20link?icon=K)](https://www.infomaniak.com/goto/fr/home?utm_term=6151f412daf35)
[![Express VPN](https://badgen.net/badge/Express%20VPN/Affiliated%20link?icon=K)](https://www.xvinlink.com/?a_fid=TontonJo)  
## Informations:

This little tool aim to get smalls one-time configurations for Proxmox Virtual environement and backup server hosts in no time.
It automatically will find if the host is a pve or a pbs host and setup accordingly.  
You can watch a demonstration of the tool [in this playlist](https://www.youtube.com/playlist?list=PLU73OWQhDzsTpLpVNspJ14rVrXAmo2Biu) 

![screenshot](https://i.ibb.co/nDXnvB4/image.png)  
## Features are:
- Automatic PVE / PBS host detection
- Hide enterprise repo and set no-subscription repository
- Update host, and when no-enterprise source is set - disable no-subscription message
- Install usefull dependencies: ifupdown2 - git - sudo - libsasl2-modules - snmp
- Enhance security a bit with the following:
- - Enable fail 2 ban with default configuration for sshd, proxmox virtual environement and backup server  
(credits to [inettgmbh](https://github.com/inettgmbh/fail2ban-proxmox-backup-server))  
- - Create another user with sudo rights
- - Disable root ssh login
- - Create another Proxmox administrator 
- - Disabling root@pam user (needed to update from GUI - update can still be don trough ssh)
- Change swappiness value or disable SWAP
- Enable S.M.A.R.T self-tests on all supported drives
- - short: every sunday@22 - Long: every 1st of month @22
- Enable SNMP V2 or v3 - you choose - with a default working configuration
- Configure email service to send system and proxmox notifications (postfix)
- Backup and restore Proxmox Virtual Environment and Backup Server configuration
- - Please find more informations below  

## USAGE
You can use this tool either with:
```shell
apt-get install git
```  
```shell
git clone https://github.com/Tontonjo/proxmox_toolbox.git
```
```shell
bash proxmox_toolbox/proxmox_toolbox.sh
```
OR
```shell
wget -q https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh
```
```shell
bash proxmox_toolbox.sh
```

## Backup and Restauration:  
- Be carefull has this was not extensively tested - especially not with cluster configurations
- The following folders and configurations are backuped by default:  
PVE:  
```/etc/ssh/sshd_config /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/pve/ /etc/lvm/ /etc/modprobe.d/ /var/lib/pve-firewall/ /var/lib/pve-cluster/  /etc/vzdump.conf /etc/ksmtuned.conf```  
PBS:  
```/etc/ssh/sshd_config /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/proxmox-backup/```

### Backup
The script will put every folder listed in pve_backup_content or pbs_backup_content in a tar.gz archive.  
- You cand add /remove folder trough the edit of backup_content= line in the script
- You can change the target folder to use for backup and restoration in the script env. variables at: backupdir="/root/"

Once the backup is done, a tar.gz archive is located at backupdir="/root/".  

### Restauration:  
The script looks for tar.gz files located in backupdir="/root/" and will list all the available archives for you to choose one.  
- The restauration will override any existing file with the one in archive  
- It will install missing dependencies for snmp and fail2ban if config were existing  

## Mountpoint and zpool

In order to recover datastores residing on other storages that still live in the system, you can do the following:

#### Directory:
- Once the restauration is done, find and open all .mount files in /etc/systemd/system/ and take note of all [Mount] values: Options Type What Where  
- run the following commands with the values you just retreived
```shell
mkdir -p "where"
echo "what where Type Options 0 2" >> /etc/fstab  
mount -a
```  
- Control if the drives are now correctly mounted  
#### Zpool:  
- run 
```shell
zpool import
```  
- Take not of "pool" name  
- run
```shell
zpool import -f poolname
```  

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

## TODO:  
settings for zram -> https://pve.proxmox.com/wiki/Zram  
PBS: add support for user creation and backup / restoration
user creation fro PBS when available  
make things stupid-proof (deny characters when numbers expected ans so on)  
add "sleep" when needed to read output  
Cosmetic corrections 

Tontonjo - 2021
