freebsd_jail
============

[![Build Status](https://travis-ci.org/vbotka/ansible-freebsd-jail.svg?branch=master)](https://travis-ci.org/vbotka/ansible-freebsd-jail)

[Ansible role.](https://galaxy.ansible.com/vbotka/freebsd_jail/) FreeBSD Jails' Management.


Requirements
------------

- Preconfigured network, firewall and NAT is required.
- ZFS is recommended.


Recommended
-----------

- Configure Network [vbotka.freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network/)
- Configure PF firewall [vbotka.freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)
- Configure ZFS [vbotka.freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs/)
- Configure Poudriere [vbotka.freebsd_poudriere](https://galaxy.ansible.com/vbotka/freebsd_poudriere/)


Variables
---------

(WIP). Review defaults and examples in vars.

Parameters of the jails are configured in the the variable
**bsd_jail_jails**

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
    jail_conf:
      - {key: "mount.devfs"}
    ezjail_conf: []
```

, or in the files from the directory **bsd_jail_objects_dir**

```
bsd_jail_objects_dir: "{{ playbook_dir }}/jail-objects.d"
```

See example of the configuration file below.

```
# cat test-02.conf
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
    jail_conf:
      - {key: "mount.devfs"}
    ezjail_conf: []
```



To remove a jail keep the entry in the variable, or in the file and set

```
    start: false
    present: false
```

Workflow
--------

1) Change shell to /bin/sh.

```
# ansible server -e 'ansible_shell_type=csh ansible_shell_executable=/bin/csh' -a 'sudo pw usermod freebsd -s /bin/sh'
```

2) Install role.

```
# ansible-galaxy install vbotka.freebsd_jail
```

3) Fit variables.

```
# editor vbotka.freebsd_jail/vars/main.yml
```

4) Create playbook and inventory.

```
# cat jail.yml

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
ansible_python_interpreter=/usr/local/bin/python3.6
ansible_perl_interpreter=/usr/local/bin/perl
```

5) Install and configure ezjail.

```
# ansible-playbook jail.yml
```

6) Test connection with the jail.
```
# ansible test_01 -m setup | grep ansible_distribution_release
        "ansible_distribution_release": "12.0-RELEASE",
```

List jails
----------

```
# ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  34   127.0.2.2       test_02                        /local/jails/test_02
    34   wlan0|10.1.0.52

```

Archive jail
-------------

```
# ezjail-admin stop test_02
# ezjail-admin archive test_02
 ll /export/archive/jails/ezjail_archives/
total 224008
drwxr-x---  2 root  wheel        512 Mar  4 17:05 ./
drwxr-x---  3 root  wheel        512 Mar  4 11:41 ../
-rw-r--r--  1 root  wheel  114663346 Mar  4 17:05 test_02-201903041704.59.tar.gz
```

Delete jail
-----------

```
# ezjail-admin delete -wf test_02
```

Restore and Start jail
----------------------

```
# ezjail-admin restore test_02-201903041704.59.tar.gz
# ezjail-admin list
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

Restore and Start jail with Ansible
-----------------------------------

To restore a jail from an archive set the parameter *archive* to the filename of the archive. Set *firstboot: "/usr/bin/true"* to avoid any changes and to set */var/db/jail-stamps/test_02-firstboot*. Keep other atributes of the object from which the archive was created.

```
# cat test-02.conf
---
objects:
  - jailname: "test_02"
    present: true
    start: true
    archive: "test_02-201903041704.59.tar.gz"
    firstboot: "/usr/bin/true"
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

Example 1. Variables of recommended roles
-----------------------------------------

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

Example 2. Ansible flavour tarball
----------------------------------
See [contrib/jail-flavours](https://github.com/vbotka/ansible-freebsd-jail/tree/master/contrib/jail-flavours)

```
# tar tvf ansible.tar 
-rwxr-xr-x root/wheel      274 2019-02-27 16:06 root/firstboot.sh
-rw-r--r-- root/wheel       39 2019-02-17 08:47 etc/resolv.conf
-rwxr-xr-x root/wheel     1821 2019-02-17 08:47 etc/rc.d/ezjail.flavour.default
-rw------- admin/admin     738 2019-03-10 21:04 home/admin/.ssh/authorized_keys
-r--r----- admin/admin    3712 2019-03-10 21:05 usr/local/etc/sudoers
-rw-rw-r-- admin/admin      39 2019-03-10 21:05 etc/rc.conf
```

```
# tree -a /local/jails/flavours/ansible
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

Example 3. Ansible firstboot.sh
-------------------------------
```
#!/bin/sh
env ASSUME_ALWAYS_YES=YES pkg install sudo
env ASSUME_ALWAYS_YES=YES pkg install perl5
env ASSUME_ALWAYS_YES=YES pkg install python36
pw useradd -n admin -s /bin/sh -m
chown -R admin:admin /home/admin
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers
```

References
----------

- [FreeBSD Handbook - Chapter 14. Jails](https://www.freebsd.org/doc/handbook/jails.html)
- [FreeBSD Handbook - 14.6. Managing Jails with ezjail](https://www.freebsd.org/doc/handbook/jails-ezjail.html)
- [erdgeist.org - ezjail - Jail administration framework](http://erdgeist.org/arts/software/ezjail/)
- [FreeBSD man - jail - Manage system jails](https://www.freebsd.org/cgi/man.cgi?jail(8))
- [FreeBSD Forums - Quick setup of jail on ZFS using ezjail with PF NAT](https://forums.freebsd.org/threads/howto-quick-setup-of-jail-on-zfs-using-ezjail-with-pf-nat.30063/)
- [FreeBSD Forums - Trying to understand jail networking](https://forums.freebsd.org/threads/trying-to-understand-jail-networking.54046/)
- [FreeBSD Forums - How to create a ZFS dataset within a jail?](https://forums.freebsd.org/threads/how-to-create-a-zfs-dataset-within-a-jail.62198/)
- [FreeBSD Forums - Best practice: jails](https://forums.freebsd.org/threads/best-practice-jails.44596/)
- [FreeNAS Forums - Can't get iocage jail to have internet connectivity(ping: ssend socket: Operation not permitted)](https://forums.freenas.org/index.php?threads/cant-get-iocage-jail-to-have-internet-connectivity.62905/)

License
-------

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)


Author Information
------------------

[Vladimir Botka](https://botka.link)
