# proxmox_toolbox

## Tonton Jo - 2021
Join me on Youtube: https://www.youtube.com/c/tontonjo

This little tool aim to get smalls one-time configurations for Proxmox Virtual environement and backup server hosts in no time.

If you find this usefull, please think about [Buying me a coffee](https://www.buymeacoffee.com/tontonjo)
and to [Subscribe to my youtube channel](http://youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw?sub_confirmation=1)

![screenshot](https://i.ibb.co/DMPZDjM/Screenshot-2021-06-16-084542.png)  
## Features are:
- Install usefull dependencies: ifupdown2, git, sudo
- Enhance security a bit with the following:
- - Enable fail 2 ban with default configuration for sshd, proxmox virtual environement and backup server (credits to [inettgmbh](https://github.com/inettgmbh/fail2ban-proxmox-backup-server))
- - Create another user with sudo rights
- - Disable root ssh login
- - Create another Proxmox administrator and disabling pve@root user
- Change swappiness value or disable SWAP
- Enable S.M.A.R.T self-tests on all supported drives
- - short: every sunday@22 - Long: every 1st of month @22
- Configure email service to send system and proxmox notifications (postfix)
- Enable SNMP V2 or v3 - you choose - with a default working configuration
- Hide enterprise repo and set no-subscription repository
- Update host, and when no-enterprise source is set - disable no-subscription message


## USAGE
You can use this tool either with:
```shell
git clone https://github.com/Tontonjo/proxmox_toolbox.git
```
```shell
bash proxmox_toolbox/proxmox_toolbox.sh
```
OR
```shell
wget https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh
```
```shell
bash proxmox_toolbox.sh
```
If you find this usefull, please think about [Buying me a coffee](https://www.buymeacoffee.com/tontonjo)
and to [Subscribe to my youtube channel](http://youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw?sub_confirmation=1)

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


## TODO:  
settings for zram -> https://pve.proxmox.com/wiki/Zram  
user creation fro PBS when available  
make things stupid-proof (deny characters when numbers expected ans so on)  
add "sleep" when needed to read output  
Cosmetic corrections  
