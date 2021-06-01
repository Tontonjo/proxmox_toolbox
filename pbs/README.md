# fail2ban-proxmox-backup-server

Fail2Ban for Proxmox Backup Server (PBS)

filter and jail for fail2ban protecting a Proxmox Backup Server (PBS) from brute force attacks to the API/WebGUI

# Installation

## Install fail2ban on a Proxmox Backup Server

```
apt -y update; apt -y install fail2ban
```

## Add the configs from this repository

```
# Download or clone this repository
git clone https://github.com/inettgmbh/fail2ban-proxmox-backup-server.git

# Put filter.d/proxmox-backup-server.conf contents to /etc/fail2ban/filter.d/proxmox-backup-server.conf
cp filter.d/proxmox-backup-server.conf /etc/fail2ban/filter.d/proxmox-backup-server.conf

# Put jail.d/proxmox-backup-server.conf to /etc/fail2ban/jail.d/proxmox-backup-server.conf
cp jail.d/proxmox-backup-server.conf /etc/fail2ban/jail.d/proxmox-backup-server.conf

# Restart Fail2Ban Service
systemctl restart fail2ban.service
```

## Check if new jail is active

```
fail2ban-client status

Status
|- Number of jail:	2
`- Jail list:	proxmox-backup-server, sshd
```

```
fail2ban-client status proxmox-backup-server

Status for the jail: proxmox-backup-server
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/proxmox-backup/api/auth.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:
```
