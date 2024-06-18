# freebsd_jail

[![quality](https://img.shields.io/ansible/quality/27910)](https://galaxy.ansible.com/vbotka/freebsd_jail)
[![Build Status](https://app.travis-ci.com/vbotka/ansible-freebsd-jail.svg?branch=master)](https://app.travis-ci.com/vbotka/ansible-freebsd-jail)

[Ansible role.](https://galaxy.ansible.com/vbotka/freebsd_jail/) FreeBSD Jails' Management.

Feel free to [share your feedback and report issues](https://github.com/vbotka/ansible-freebsd-jail/issues).

[Contributions are welcome](https://github.com/firstcontributions/first-contributions).


## Synopsis

This role uses *ezjail* to manage FreeBSD jails. In most cases it is more efficient to use
*iocage*. See the Ansible module [iocage](https://github.com/vbotka/ansible-iocage).


## Supported platforms

This role has been developed and tested with [FreeBSD Supported Production Releases](https://www.freebsd.org/releases/).


## Requirements

### Roles

- [vbotka.freebsd_postinstall](https://galaxy.ansible.com/vbotka/freebsd_postinstall)

### Collections

- ansible.posix
- community.general

### Other

- Preconfigured network, ZFS, firewall and NAT is required.


## Recommended roles

- Configure Network [vbotka.freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network/)
- Configure PF firewall [vbotka.freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)
- Configure ZFS [vbotka.freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs/)
- Configure Poudriere [vbotka.freebsd_poudriere](https://galaxy.ansible.com/vbotka/freebsd_poudriere/)


## Jail type

This role is tested with jailtype zfs only.


## Variables

See the defaults and examples in vars.

Parameters of the jails are configured in the the variable *bsd_jail_jails*

```yaml
bsd_jail_jails:
  - jailname: test_01
    present: true                               # default=true
    start: true                                 # default=true
    jailtype: zfs
    flavour: ansible                            # optional
    interface:
      - {dev: lo1, ip4: 127.0.2.1}
      - {dev: em0, ip4: 10.1.0.51}
    parameters:                                 # default([])
      - {key: allow.raw_sockets, val: "true"}
      - {key: allow.set_hostname, val: "true"}
    jail_conf:                                  # default([])
      - {key: mount.devfs}
    ezjail_conf: []                             # default([])
    firstboot: /root/firstboot.sh               # optional
    firstboot_owner: root                       # default=root
    firstboot_group: wheel                      # default=wheel
    firstboot_mode: '0750'                      # default='0755'
```

,or in the files stored in the directory *bsd_jail_objects_dir*. For
example,

```yaml
bsd_jail_objects_dir: "{{ playbook_dir }}/jails/jail.d"
```

See the example of the configuration file below

```yaml
shell> cat test_02.yml
---
objects:
  - jailname: test_02
    present: true
    start: true
    jailtype: zfs
    flavour: ansible
    interface:
      - {dev: lo1, ip4: 127.0.2.2}
      - {dev: em0, ip4: 10.1.0.52}
    parameters:
      - {key: allow.raw_sockets, val: "true"}
      - {key: allow.set_hostname, val: "true"}
    jail_conf:
      - {key: mount.devfs}
    ezjail_conf: []
    firstboot: /root/firstboot.sh
    firstboot_owner: root
    firstboot_group: wheel
    firstboot_mode: '0750'
```

To remove a jail keep the entry in the variable, or in the file and set

```yaml
objects:
  - jailname: test_02
    start: false
    present: false
    ...
```

See
[contrib/jail-objects](https://github.com/vbotka/ansible-freebsd-jail/tree/devel/contrib/jail-objects)
playbook and template to create the YAML files with the jail objects.


## Flavours

See the chapter *Flavours* from the [ezjail – Jail administration
framework](https://erdgeist.org/arts/software/ezjail/). Quoting:

> A set of files to copy, packages to install and scripts to execute
   is called "flavour".

See
[contrib/jail-flavours](https://github.com/vbotka/ansible-freebsd-jail/tree/devel/contrib/jail-flavours)
on how to create and configure ezjail flavours.


## Portsnap cron (optional)

See the chapter *The basejail* from the [ezjail – Jail administration
framework](https://erdgeist.org/arts/software/ezjail/). The command
*ezjail-admin install* may ask *portsnap* to (-p) fetch and extract a
FreeBSD ports tree (see *man ezjail-admin*). This may take a while. You
might want to speedup the execution of the role and fetch the ports tree by
cron (see the *cron* command in *man portsnap*). Optionally, use the role
[vbotka.ansible-freebsd-ports](https://github.com/vbotka/ansible-freebsd-ports/tree/master)
to configure *portsnap cron*.


## Workflow

1) Change shell to /bin/sh if necessary

```bash
shell> ansible server -e 'ansible_shell_type=csh ansible_shell_executable=/bin/csh' -a 'sudo pw usermod admin -s /bin/sh'
```

2) Install roles

```bash
shell> ansible-galaxy role install vbotka.freebsd_jail
shell> ansible-galaxy role install vbotka.freebsd_postinstall
```

3) Fit variables. For example, in vars/main.yml

```bash
shell> editor vbotka.freebsd_jail/vars/main.yml
```

4) Create playbook and inventory

```yaml
shell> cat jail.yml
- hosts: server
  roles:
    - vbotka.freebsd_jail
```

```ini
# cat hosts
[server]
<server1_ip-or-fqdn>
<server2_ip-or-fqdn>
[server:vars]
ansible_connection=ssh
ansible_user=admin
ansible_python_interpreter=/usr/local/bin/python3.9
ansible_perl_interpreter=/usr/local/bin/perl
```

5) Install and configure ezjail

Check syntax

```bash
shell> ansible-playbook freebsd-jail.yml --syntax-check
```

Take a look at the variables

```bash
shell> ansible-playbook jail.yml -t bsd_jail_debug -e bsd_jail_debug=true
```

Install packages

```bash
shell> ansible-playbook jail.yml -t bsd_jail_packages -e bsd_jail_install=true
```

Create directory flavours and unarchive files

```bash
shell> ansible-playbook jail.yml -t bsd_jail_ezjail_flavours -e bsd_ezjail=true
```

Dry-run the play and show the changes

```bash
shell> ansible-playbook jail.yml --check --diff
```

Run the play

```bash
shell> ansible-playbook jail.yml
```

6) Create inventory and test the connection to the jails

```ini
shell> cat hosts
[test]
test_01
test_02
test_03

[test:vars]
ansible_connection=ssh
ansible_user=admin
ansible_become=yes
ansible_become_user=root
ansible_become_method=sudo
ansible_python_interpreter=/usr/local/bin/python3.8
ansible_perl_interpreter=/usr/local/bin/perl
```

```bash
shell> ansible test_01 -m setup | grep ansible_distribution_release
        "ansible_distribution_release": "13.2-RELEASE",
```


## List jails

```bash
shell> ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  13   127.0.2.3       test_03                        /local/jails/test_03
    13   em0|10.1.0.53
ZR  12   127.0.2.2       test_02                        /local/jails/test_02
    12   em0|10.1.0.52
ZR  11   127.0.2.1       test_01                        /local/jails/test_01
    11   em0|10.1.0.51
```


## Archive jail

```bash
shell> jexec 11 /etc/rc.shutdown
shell> ezjail-admin stop test_01
  ...
shell> ezjail-admin archive -A
shell> ls -1 /export/archive/jails/ezjail_archives/
test_01-202311060342.38.tar.gz
test_02-202311060342.18.tar.gz
test_03-202311060341.58.tar.gz
```


## Stop and delete jail

```bash
shell> jexec 12 /etc/rc.shutdown
 Stopping sshd.
 Waiting for PIDS: 6759.
 Stopping cron.
 Waiting for PIDS: 6769.
 .
 Terminated
 ```
 ```bash
shell> ezjail-admin delete -wf test_02
Stopping jails:/etc/rc.d/jail: WARNING: /var/run/jail.test_02.conf is created and used for jail test_02.
 test_02.
```
```bash
# ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  13   127.0.2.3       test_03                        /local/jails/test_03
    13   em0|10.1.0.53
ZR  11   127.0.2.1       test_01                        /local/jails/test_01
    11   em0|10.1.0.51
```

## Restore and Start jail

```bash
shell> ezjail-admin restore test_02-202311060342.18.tar.gz
```
```bash
shell> ezjail-admin start test_02
```
```
shell> ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  13   127.0.2.3       test_03                        /local/jails/test_03
    13   em0|10.1.0.53
ZR  14   127.0.2.2       test_02                        /local/jails/test_02
    14   em0|10.1.0.52
ZR  11   127.0.2.1       test_01                        /local/jails/test_01
    11   em0|10.1.0.51
```


## Restore a jail with Ansible

Set the attribute *archive*. For example,

```yaml
shell> cat test_02.conf
---
objects:
  - jailname: test_02
    present: true
    start: true
    archive: test_02-202311060342.18.tar.gz
    jailtype: zfs
    flavour: ansible
    interface:
      - {dev: lo1, ip4: 127.0.2.2}
      - {dev: em0, ip4: 10.1.0.52}
    parameters:
      - {key: allow.raw_sockets, val: "true"}
      - {key: allow.set_hostname, val: "true"}
    jail_conf:
      - {key: mount.devfs}
    ezjail_conf: []
    firstboot: /root/firstboot.sh
    firstboot_owner: root
    firstboot_group: wheel
    firstboot_mode: '0750'
```

If the jail does not exist it will be restored from the archive if the
parameter *bsd_ezjail_admin_restore* is set *true*
(*default=false*). Speedup the play by selecting the tag
*bsd_jail_ezjail_jails*

```bash
ansible-playbook jail.yml -e bsd_ezjail_admin_restore=true -t bsd_jail_ezjail_jails
```

If the jail is restored from the archive a *jail-stamp* is
created. This prevents the play from running the script in the
attribute *firstboot*. See the stamps

```bash
shell> ls -1 /var/db/jail-stamps/
test_01-firstboot
test_02-firstboot
test_03-firstboot
```

Start the jail

```bash
shell> ezjail-admin start test_02
```
```bash
# ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZR  13   127.0.2.3       test_03                        /local/jails/test_03
    13   em0|10.1.0.53
ZR  17   127.0.2.2       test_02                        /local/jails/test_02
    17   em0|10.1.0.52
ZR  11   127.0.2.1       test_01                        /local/jails/test_01
    11   em0|10.1.0.51
```

If the restoration is disabled or the attribute *archive* is not
defined new jail will be created.


## my-jail-admin.sh

[my-jail-admin.sh](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/bin/my-jail-admin.sh)
is a script to facilitate the automation of jail's management. Once a jail has been created,
configured and archived it's easier to use
[my-jail-admin.sh](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/bin/my-jail-admin.sh)
to delete and restore the jail. my-jail-admin.sh is not installed by default and should be manually
copied if needed.

### Examples

```bash
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

* [freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network)

```yaml
fn_gateway_enable: true
fn_defaultrouter: 10.1.0.10

fn_interfaces:
  - {interface: em0, options: "inet 10.1.0.75 netmask 255.255.255.0"}

fn_aliases:
  - interface: em0
    aliases:
      - {alias: alias1, options: "inet 10.1.0.51 netmask 255.255.255.255"}
      - {alias: alias2, options: "inet 10.1.0.52 netmask 255.255.255.255"}
      - {alias: alias3, options: "inet 10.1.0.53 netmask 255.255.255.255"}

fn_cloned_interfaces:
  - {interface: lo1, state: present}
```
```bash
shell> ansible-playbook freebsd-network.yml
```

* [freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs)

```yaml
fzfs_enable: true
fzfs_manage:
  - name: zroot/jails
    state: present
    extra_zfs_properties:
      compression: 'on'
      mountpoint: /local/jails
fzfs_mountpoints:
  - mountpoint: /local/jails
    owner: root
    group: wheel
    mode: '0700'
```
```
shell> ansible-playbook freebsd-zfs.yml
```

* [freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)

```yaml
pf_blacklistd_enable: true
pf_fail2ban_enable: true
pf_relayd_enable: false
pf_sshguard_enable: true

pfconf_only: false
pfconf_validate: true

# blacklistd
pf_blacklistd_flags: '-r'
pf_blacklistd_conf_remote: []
pf_blacklistd_conf_local:
  - {adr: ssh, type: stream, proto: '*', owner: '*', name: '*', nfail: '3', disable: 24h}
  - {adr: ftp, type: stream, proto: '*', owner: '*', name: '*', nfail: '3', disable: 24h}
  - {adr: smtp, type: stream, proto: '*', owner: '*', name: '*', nfail: '3', disable: 24h}
  - {adr: smtps, type: stream, proto: '*', owner: '*', name: '*', nfail: '3', disable: 24h}
  - {adr: submission, type: stream, proto: '*', owner: '*', name: '*', nfail: '3', disable: 24h}
  - {adr: '*', type: '*', proto: '*', owner: '*', name: '*', nfail: '3', disable: '60'}
pf_blacklistd_rcconf:
  - {regexp: blacklistd_flags, line: "{{ pf_blacklistd_flags }}"}

# /etc/pf.conf

pf_type: default

pf_ext_if: em0
pf_logall_blocked: log
pf_pass_icmp_types: [echoreq, unreach]
pf_pass_icmp6_types: [echoreq, unreach]
pf_jails_net: 10.1.0.0/24
pf_rules_rdr:
  - rdr pass on $ext_if proto tcp from any to 10.1.0.51 port { 80 443 8080 8081 } -> 127.0.2.1  # test_01
  - rdr pass on $ext_if proto tcp from any to 10.1.0.52 port { 80 443 } -> 127.0.2.2            # test_02
  - rdr pass on $ext_if proto tcp from any to 10.1.0.53 port { 80 443 } -> 127.0.2.3            # test_03
  - rdr pass on $ext_if proto tcp from any to 10.1.0.54 port { 80 443 } -> 127.0.2.4            # test_04
  - rdr pass on $ext_if proto tcp from any to 10.1.0.55 port { 80 443 } -> 127.0.2.5            # test_05
  - rdr pass on $ext_if proto tcp from any to 10.1.0.56 port { 80 443 } -> 127.0.2.6            # test_06
  - rdr pass on $ext_if proto tcp from any to 10.1.0.57 port { 80 443 } -> 127.0.2.7            # test_07
  - rdr pass on $ext_if proto tcp from any to 10.1.0.58 port { 80 443 } -> 127.0.2.8            # test_08
  - rdr pass on $ext_if proto tcp from any to 10.1.0.59 port { 80 443 } -> 127.0.2.9            # test_09
  - rdr pass on $ext_if proto tcp from any to 10.1.0.60 port { 80 443 } -> 127.0.2.10           # test_10

pf_macros:
  ext_if: "{{ pf_ext_if }}"
  localnet: "{{ pf_jails_net }}"
  logall: "{{ pf_logall_blocked }}"
  icmp_types: "{{ pf_pass_icmp_types }}"
  icmp6_types: "{{ pf_pass_icmp6_types }}"

pf_options:
  - set skip on lo0
  - set block-policy return
  - set loginterface $ext_if

pf_tables:
  - table <sshabuse> persist

pf_normalization:
  - scrub in on $ext_if all fragment reassemble

pf_translation:
  - "{{ pf_rules_rdr }}"
  - nat on $ext_if from $localnet to any -> ($ext_if)

pf_filtering:
  - antispoof for $ext_if
  - "{{ pf_anchors }}"
  - block $logall all
  - pass inet proto icmp all icmp-type $icmp_types
  - pass inet6 proto icmp6 all icmp6-type $icmp6_types
  - pass from { self, $localnet } to any keep state
```
```
shell> ansible-playbook freebsd-pf.yml
```

* [freebsd_postinstall](https://galaxy.ansible.com/vbotka/freebsd_postinstall)

```yaml
fp_sysctl:
  - {name: net.inet.ip.forwarding, value: 1}
  - {name: vfs.zfs.prefetch.disable, value: 0}
  - {name: security.jail.set_hostname_allowed, value: 1}
  - {name: security.jail.socket_unixiproute_only, value: 1}
  - {name: security.jail.sysvipc_allowed, value: 0}
  - {name: security.jail.allow_raw_sockets, value: 0}
  - {name: security.jail.chflags_allowed, value: 0}
  - {name: security.jail.jailed, value: 0}
  - {name: security.jail.enforce_statfs, value: 2}
```

To manage ZFS inside the jail add the following states

```yaml
  - {name: security.jail.mount_allowed, value: '1'}
  - {name: security.jail.mount_devfs_allowed, value: '1'}
  - {name: security.jail.mount_zfs_allowed, value: '1'}
```
```bash
shell> ansible-playbook freebsd-postinstall.yml -t fp_sysctl
```

## Example 2. Ansible flavour tarball

See [contrib/jail-flavours](https://github.com/vbotka/ansible-freebsd-jail/tree/master/contrib/jail-flavours)

```bash
shell> tar tvf ansible.tar 
-rw------- admin/admin    1475 2023-11-04 14:52 home/admin/.ssh/authorized_keys
-rwxr-x--- root/wheel      855 2023-11-04 14:52 root/firstboot.sh
-r--r----- root/wheel     3978 2023-11-04 14:54 usr/local/etc/sudoers
-rw-r--r-- root/wheel       39 2023-11-04 14:52 etc/resolv.conf
-rw-r--r-- root/wheel       39 2023-11-04 14:52 etc/rc.conf
-rwxr-xr-x root/wheel     1821 2023-11-04 14:52 etc/rc.d/ezjail.flavour.default
```

```bash
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

See [contrib/jail-flavours/firstboot-1.0.1](https://github.com/vbotka/ansible-freebsd-jail/blob/master/contrib/jail-flavours/firstboot-1.0.1)

```bash
#!/bin/sh
# Install packages
env ASSUME_ALWAYS_YES=YES pkg install sudo
env ASSUME_ALWAYS_YES=YES pkg install perl5
env ASSUME_ALWAYS_YES=YES pkg install python38
env ASSUME_ALWAYS_YES=YES pkg install gtar
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
# Configure root
chown root:wheel root/firstboot.sh
# Configure etc
chown root:wheel etc/rc.conf
chmod 0644 etc/rc.conf
chown root:wheel etc/resolv.conf
chmod 0644 etc/resolv.conf
chown root:wheel etc/rc.d/ezjail.flavour.default
chmod 0755 etc/rc.d/ezjail.flavour.default
# EOF
```

## Known issues

### 'Error: No archive for pattern __ can be found.'

Restoration of a jail from an archive fails

```yaml
TASK [vbotka.freebsd_jail : ezjail-jails:create: Debug ezjail-admin command] ***************************************
ok: [srv.example.com] =>
  local_command: ezjail-admin restore  test_13-202201162054.07.tar.gz && touch /var/db/jail-stamps/test_13-firstboot

TASK [vbotka.freebsd_jail : ezjail-jails:create: Create or Restore jail test_13] ***********************************
fatal: [srv.example.com]: FAILED! => changed=true
  cmd:
  - ezjail-admin
  - restore
  - test_13-202201162054.07.tar.gz
  - '&&'
  - touch
  - /var/db/jail-stamps/test_13-firstboot
  delta: '0:01:05.721641'
  end: '2022-01-16 23:58:13.516263'
  msg: non-zero return code
  rc: 1
  start: '2022-01-16 23:57:07.794622'
  stderr: 'Error: No archive for pattern __ can be found.'
```


## References

- [Jails - FreeBSD Handbook](https://www.freebsd.org/doc/handbook/jails.html)
- [ezjail Jail administration framework - erdgeist.org](http://erdgeist.org/arts/software/ezjail/)
- [jail - FreeBSD man](https://www.freebsd.org/cgi/man.cgi?jail(8))
- [Quick setup of jail on ZFS using ezjail with PF NAT - FreeBSD Forums](https://forums.freebsd.org/threads/howto-quick-setup-of-jail-on-zfs-using-ezjail-with-pf-nat.30063/)
- [Trying to understand jail networking - FreeBSD Forums](https://forums.freebsd.org/threads/trying-to-understand-jail-networking.54046/)
- [How to create a ZFS dataset within a jail? - FreeBSD Forums](https://forums.freebsd.org/threads/how-to-create-a-zfs-dataset-within-a-jail.62198/)
- [Best practice: jails - FreeBSD Forums](https://forums.freebsd.org/threads/best-practice-jails.44596/)
- [Can't get iocage jail to have internet connectivity - FreeNAS Forums](https://forums.freenas.org/index.php?threads/cant-get-iocage-jail-to-have-internet-connectivity.62905/)
- [FreeBSD Mastery: Jails, Michael W. Lucas](https://mwl.io/nonfiction/os#fmjail)


## License

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)


## Author Information

[Vladimir Botka](https://botka.info)
