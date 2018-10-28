freebsd_jail
==============

[![Build Status](https://travis-ci.org/vbotka/ansible-freebsd-jail.svg?branch=master)](https://travis-ci.org/vbotka/ansible-freebsd-jail)

[Ansible role.](https://galaxy.ansible.com/vbotka/freebsd_jail/) FreeBSD Jail Management.


Requirements
------------

Preconfigured network, firewall, NAT and ZFS(recommended) is required.


Recommended
-----------

- Configure Network [vbotka.freebsd_network](https://galaxy.ansible.com/vbotka/freebsd_network/)
- Configure ZFS [vbotka.freebsd_zfs](https://galaxy.ansible.com/vbotka/freebsd_zfs/)
- Configure PF firewall [vbotka.freebsd_pf](https://galaxy.ansible.com/vbotka/freebsd_pf)
- Configure Poudriere [vbotka.freebsd_poudriere](https://galaxy.ansible.com/vbotka/freebsd_poudriere/)


Variables
---------

TBD. Review defaults and examples in vars.


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
ansible_user=freebsd
ansible_python_interpreter=/usr/local/bin/python2.7
ansible_perl_interpreter=/usr/local/bin/perl
```

5) Install and configure ezjail.

```
# ansible-playbook jail.yml
```
		

References
----------

- [FreeBSD Handbook - Chapter 14. Jails](https://www.freebsd.org/doc/handbook/jails.html)
- [FreeBSD Handbook - 14.6. Managing Jails with ezjail](https://www.freebsd.org/doc/handbook/jails-ezjail.html)
- [Quick setup of jail on ZFS using ezjail with PF NAT](https://forums.freebsd.org/threads/howto-quick-setup-of-jail-on-zfs-using-ezjail-with-pf-nat.30063/)
- [ezjail - Jail administration framework](http://erdgeist.org/arts/software/ezjail/)
- [jail - Manage system jails](https://www.freebsd.org/cgi/man.cgi?jail(8))
- [Trying to understand jail networking](https://forums.freebsd.org/threads/trying-to-understand-jail-networking.54046/)
- [Can't get iocage jail to have internet connectivity(ping: ssend socket: Operation not permitted)](https://forums.freenas.org/index.php?threads/cant-get-iocage-jail-to-have-internet-connectivity.62905/)

License
-------

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)


Author Information
------------------

[Vladimir Botka](https://botka.link)
