# freebsd_jail

[![quality](https://img.shields.io/ansible/quality/27910)](https://galaxy.ansible.com/vbotka/freebsd_jail)[![Build Status](https://travis-ci.org/vbotka/ansible-freebsd-jail.svg?branch=master)](https://travis-ci.org/vbotka/ansible-freebsd-jail)

[Ansible role.](https://galaxy.ansible.com/vbotka/freebsd_jail/) FreeBSD Jails' Management.

Feel free to [share your feedback and report issues](https://github.com/vbotka/ansible-freebsd-jail/issues).

[Contributions are welcome](https://github.com/firstcontributions/first-contributions).


## Supported platforms

This role has been developed and tested with [FreeBSD Supported Production Releases](https://www.freebsd.org/releases/).

This may be different from the platforms in Ansible Galaxy which does not offer all released
versions in time and would report an error. For example: `IMPORTER101: Invalid platform:
"FreeBSD-11.3", skipping.`


## Requirements

- [vbotka.freebsd_postinstall](https://galaxy.ansible.com/vbotka/freebsd_postinstall)
- Preconfigured network, firewall and NAT is required.
- ZFS is recommended.


## Recommended

- Configure Network [vbotka.freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network/)
- Configure PF firewall [vbotka.freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)
- Configure ZFS [vbotka.freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs/)
- Configure Poudriere [vbotka.freebsd_poudriere](https://galaxy.ansible.com/vbotka/freebsd_poudriere/)


## Variables

Review the defaults and examples in vars.

Parameters of the jails are configured in the the variable *bsd_jail_jails*

```
bsd_jail_jails:
  - jailname: "test_01"
    present: true
    start: true
    jailtype: "zfs"
    flavour: "ansible"
    firstboot: "/root/firstboot.sh"
    interface:
      - {dev: "lo1", ip4: "127.0.2.1"}
      - {dev: "wlan0", ip4: "10.1.0.51"}
    parameters:
      - {key: "allow.raw_sockets", val: "true"}
      - {key: "allow.set_hostname", val: "true"}
    jail_conf:
      - {key: "mount.devfs"}
    ezjail_conf: []
```

,or in the files from the directory *bsd_jail_objects_dir*

```
bsd_jail_objects_dir: "{{ playbook_dir }}/jail-objects.d"
```

See the example of the configuration file below

```
shell> cat test-02.conf
---
objects:
  - jailname: "test_02"
    present: true
    start: true
    jailtype: "zfs"
    flavour: "ansible"
    firstboot: "/root/firstboot.sh"
    interface:
      - {dev: "lo1", ip4: "127.0.2.2"}
      - {dev: "wlan0", ip4: "10.1.0.52"}
    parameters:
      - {key: "allow.raw_sockets", val: "true"}
      - {key: "allow.set_hostname", val: "true"}
    jail_conf:
      - {key: "mount.devfs"}
    ezjail_conf: []
```

To remove a jail keep the entry in the variable, or in the file and set

```
    start: false
    present: false
```


## Workflow

1) Change shell to /bin/sh

```
shell> ansible server -e 'ansible_shell_type=csh ansible_shell_executable=/bin/csh' -a 'sudo pw usermod freebsd -s /bin/sh'
```

2) Install roles

```
shell> ansible-galaxy install vbotka.freebsd_jail
shell> ansible-galaxy install vbotka.freebsd_postinstall
```

3) Fit variables

```
shell> editor vbotka.freebsd_jail/vars/main.yml
```

4) Create playbook and inventory

```
shell> cat jail.yml

- hosts: server
  roles:
    - vbotka.freebsd_jail
```

```
# cat hosts
[server]
<SERVER1-IP-OR-FQDN>
<SERVER2-IP-OR-FQDN>
[server:vars]
ansible_connection=ssh
ansible_user=admin
ansible_python_interpreter=/usr/local/bin/python3.7
ansible_perl_interpreter=/usr/local/bin/perl
```

5) Install and configure ezjail

```
shell> ansible-playbook jail.yml
```

6) Test connection with the jail

```
shell> ansible test_01 -m setup | grep ansible_distribution_release
        "ansible_distribution_release": "12.0-RELEASE",
```


## List jails

```
shell> ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  34   127.0.2.2       test_02                        /local/jails/test_02
    34   wlan0|10.1.0.52

```


## Archive jail

```
shell> ezjail-admin stop test_02
shell> ezjail-admin archive test_02
shell> ll /export/archive/jails/ezjail_archives/
total 224008
drwxr-x---  2 root  wheel        512 Mar  4 17:05 ./
drwxr-x---  3 root  wheel        512 Mar  4 11:41 ../
-rw-r--r--  1 root  wheel  114663346 Mar  4 17:05 test_02-201903041704.59.tar.gz
```


## Delete jail

```
shell> ezjail-admin delete -wf test_02
```


## Restore and Start jail

```
shell> ezjail-admin restore test_02-201903041704.59.tar.gz
shell> ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZS  N/A  127.0.2.2       test_02                        /local/jails/test_02
    N/A  wlan0|10.1.0.52
# ezjail-admin start test_02
# ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  35   127.0.2.2       test_02                        /local/jails/test_02
    35   wlan0|10.1.0.52
```


## Restore and Start jail with Ansible

If the jail does not exist the jail is restored by default from the archive if the parameter archive is defined.

```
bsd_ezjail_admin_restore: true
```

To restore a jail from an archive set the parameter *archive* to the filename of the archive. For example

```
shell> cat test-02.conf
---
objects:
  - jailname: "test_02"
    present: true
    start: true
    archive: "test_02-201903041704.59.tar.gz"
    firstboot: "/root/firstboot.sh"
    jailtype: "zfs"
    flavour: "ansible"
    interface:
      - {dev: "lo1", ip4: "127.0.2.2"}
      - {dev: "wlan0", ip4: "10.1.0.52"}
    parameters:
      - {key: "allow.raw_sockets", val: "true"}
    jail_conf:
      - {key: "mount.devfs"}
    ezjail_conf: []
```

If the jail is restored from the archive a *jail-stamp* is created. This prevents the script in the
parameter *firstboot* to run. For example

```
/var/db/jail-stamps/test_02-firstboot
```

If the restoration is disabled, or the parameter *archive* is not defined new jail is created if it
does not exist yet.

```
bsd_ezjail_admin_restore: false
```


## my-jail-admin.sh

[my-jail-admin.sh](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/bin/my-jail-admin.sh)
is a script to facilitate the automation of jail's management. Once a jail has been created,
configured and archived it's easier to use
[my-jail-admin.sh](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/bin/my-jail-admin.sh)
to delete and restore the jail. my-jail-admin.sh is not installed by default and should be manually
copied if needed.

```
shell> my-jail-admin.sh delete test_01
[Logging: /tmp/my-jail-admin.test_01]
2019-03-20 12:23:58: test_01: delete: [OK]  jail-rcd:
Stopping jails: test_01.
2019-03-20 12:23:58: test_01: delete: [OK]  jail: test_01 stopped
2019-03-20 12:23:58: test_01: delete: [OK]  ezjail-admin:
 
2019-03-20 12:23:58: test_01: delete: [OK]  jail: test_01 deleted
2019-03-20 12:23:58: test_01: delete: [OK]  lock: /var/db/jail-stamps/test_01-firstboot removed

shell> my-jail-admin.sh restore test_01 test_01-firstboot
2019-03-20 12:25:32: test_01: restore: [OK]  ezjail-admin:
Warning: Some services already seem to be listening on IP 127.0.2.1
...
2019-03-20 12:25:32: test_01: restore: [OK]  jail: test_01 restored from test_01-firstboot
2019-03-20 12:25:32: test_01: restore: [OK]  lock: /var/db/jail-stamps/test_01-firstboot created
2019-03-20 12:25:33: test_01: restore: [OK]  jail-rcd:
Starting jails: test_01.
2019-03-20 12:25:33: test_01: restore: [OK]  jail: test_01 started
```


## Example 1. Variables of recommended roles

[freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network)

```
fn_cloned_interfaces:
  - interface: "lo1"
    options: []
fn_aliases:
  - interface: "wlan0"
    aliases:
      - {alias: "alias1", options: "inet 10.1.0.51  netmask 255.255.255.255", state: "present"}
      - {alias: "alias2", options: "inet 10.1.0.52  netmask 255.255.255.255"}
```

[freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs)

```
fzfs_manage:
  - name: zroot/jails
    state: present
    extra_zfs_properties:
      compression: on
      mountpoint: /local/jails
fzfs_mountpoints:
  - mountpoint: /local/jails
    owner: root
    group: wheel
    mode: "0700"
```

[freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)

```
pf_rules_nat:
  - nat on $ext_if inet from ! ($ext_if) to any -> ($ext_if)
pf_rules_rdr:
  - rdr pass on $ext_if proto tcp from any to 10.1.0.51 port { 80 443 } -> 127.0.2.1
  - rdr pass on $ext_if proto tcp from any to 10.1.0.52 port { 80 443 } -> 127.0.2.2
```

[freebsd_postinstall](https://galaxy.ansible.com/vbotka/freebsd_postinstall)

```
fp_sysctl:
  - { name: "net.inet.ip.forwarding", value: "1" }
  - { name: "security.jail.set_hostname_allowed", value: "1" }
  - { name: "security.jail.socket_unixiproute_only", value: "1" }
  - { name: "security.jail.sysvipc_allowed", value: "0" }
  - { name: "security.jail.allow_raw_sockets", value: "0" }
  - { name: "security.jail.chflags_allowed", value: "0" }
  - { name: "security.jail.jailed", value: "0" }
  - { name: "security.jail.enforce_statfs", value: "2" }
```

To manage ZFS inside the jail add the following states

```
  - { name: "security.jail.mount_allowed", value: "1" }
  - { name: "security.jail.mount_devfs_allowed", value: "1" }
  - { name: "security.jail.mount_zfs_allowed", value: "1" }
```


## Example 2. Ansible flavour tarball

See [contrib/jail-flavours](https://github.com/vbotka/ansible-freebsd-jail/tree/master/contrib/jail-flavours)

```
shell> tar tvf ansible.tar 
-rwxr-xr-x root/wheel      274 2019-02-27 16:06 root/firstboot.sh
-rw-r--r-- root/wheel       39 2019-02-17 08:47 etc/resolv.conf
-rwxr-xr-x root/wheel     1821 2019-02-17 08:47 etc/rc.d/ezjail.flavour.default
-rw------- admin/admin     738 2019-03-10 21:04 home/admin/.ssh/authorized_keys
-r--r----- admin/admin    3712 2019-03-10 21:05 usr/local/etc/sudoers
-rw-rw-r-- admin/admin      39 2019-03-10 21:05 etc/rc.conf
```

```
shell> tree -a /local/jails/flavours/ansible
/local/jails/flavours/ansible
├── etc
│   ├── rc.conf
│   ├── rc.d
│   │   └── ezjail.flavour.default
│   └── resolv.conf
├── home
│   └── admin
│       └── .ssh
│           └── authorized_keys
├── root
│   └── firstboot.sh
└── usr
    └── local
        └── etc
            └── sudoers
```


## Example 3. Ansible firstboot.sh

See [contrib/jail-flavours/firstboot.sh](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/jail-flavours/firstboot.sh)

```
#!/bin/sh                                                                                     
# Install packages                                                                            
env ASSUME_ALWAYS_YES=YES pkg install security/sudo
env ASSUME_ALWAYS_YES=YES pkg install lang/perl5.30
env ASSUME_ALWAYS_YES=YES pkg install lang/python37shell
env ASSUME_ALWAYS_YES=YES pkg install security/py-openssl
env ASSUME_ALWAYS_YES=YES pkg install archivers/gtar
# Create user admin                                                                           
pw useradd -n admin -s /bin/sh -m                                                             
chown -R admin:admin /home/admin                                                              
chmod 0700 /home/admin/.ssh                                                                   
chmod 0600 /home/admin/.ssh/authorized_keys                                                   
# Configure sudoers                                                                           
cp /usr/local/etc/sudoers.dist /usr/local/etc/sudoers                                         
chown root:wheel /usr/local/etc/sudoers                                                       
chmod 0440 /usr/local/etc/sudoers                                                             
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers                                
# EOF 
```


## References

- [FreeBSD Handbook - Chapter 14. Jails](https://www.freebsd.org/doc/handbook/jails.html)
- [FreeBSD Handbook - 14.6. Managing Jails with ezjail](https://www.freebsd.org/doc/handbook/jails-ezjail.html)
- [erdgeist.org - ezjail - Jail administration framework](http://erdgeist.org/arts/software/ezjail/)
- [FreeBSD man - jail - Manage system jails](https://www.freebsd.org/cgi/man.cgi?jail(8))
- [FreeBSD Forums - Quick setup of jail on ZFS using ezjail with PF NAT](https://forums.freebsd.org/threads/howto-quick-setup-of-jail-on-zfs-using-ezjail-with-pf-nat.30063/)
- [FreeBSD Forums - Trying to understand jail networking](https://forums.freebsd.org/threads/trying-to-understand-jail-networking.54046/)
- [FreeBSD Forums - How to create a ZFS dataset within a jail?](https://forums.freebsd.org/threads/how-to-create-a-zfs-dataset-within-a-jail.62198/)
- [FreeBSD Forums - Best practice: jails](https://forums.freebsd.org/threads/best-practice-jails.44596/)
- [FreeNAS Forums - Can't get iocage jail to have internet connectivity(ping: ssend socket: Operation not permitted)](https://forums.freenas.org/index.php?threads/cant-get-iocage-jail-to-have-internet-connectivity.62905/)


## License

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)


## Author Information

[Vladimir Botka](https://botka.link)
