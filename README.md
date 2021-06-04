# proxmox_toolbox

## Tonton Jo - 2021
Join me on Youtube: https://www.youtube.com/c/tontonjo

If you find this usefull, please think about [Buying me a coffee](https://www.buymeacoffee.com/tontonjo)
and to [Subscribe to my youtube channel](http://youtube.com/channel/UCnED3K6K5FDUp-x_8rwpsZw?sub_confirmation=1)

This little tool aim to get smalls one-time configurations for Proxmox Virtual environement and backup server hosts in no time.

Features are:
- Install usefulle dependencies: ifupdown2, git, sudo
- Hide enterprise repo and set no-subscription repository
- Configure email service to send system and proxmox notifications (postfix)
- Enhance security a bit with the following:
- -Enable fail 2 ban with default configuration for sshd, proxmox virtual environement and backup server (credits to [inettgmbh](https://github.com/inettgmbh/fail2ban-proxmox-backup-server)
- -Create another user with sudo rights
- -Disable root ssh login
- -Create another Proxmox administrator and disabling Root user

## USAGE
You can use this tool either with:
```shell
git clone https://github.com/Tontonjo/proxmox_toolbox.git
bash proxmox_toolbox/proxmox_toolbox.sh
```
OR
```shell
wget https://raw.githubusercontent.com/Tontonjo/proxmox_toolbox/main/proxmox_toolbox.sh
bash proxmox_toolbox/main/proxmox_toolbox.sh
```
