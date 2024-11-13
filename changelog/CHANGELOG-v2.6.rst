=====================================
vbotka.freebsd_jail 2.6 Release Notes
=====================================

.. contents:: Topics


2.6.5
=====

Release Summary
---------------
Add article 'Ansible FreeBSD jails'

Major Changes
-------------

Minor Changes
-------------
* Add contrib/doc/ansible-freebsd-jails.\*


2.6.4
=====

Release Summary
---------------
Maintenance update.

Major Changes
-------------

Minor Changes
-------------
* Tasks formatting improved.


2.6.3
=====

Release Summary
---------------
Maintenance update.

Major Changes
-------------

Minor Changes
-------------
* Update README.
* Fix travis formatting.


2.6.2
=====

Release Summary
---------------
Maintenance update.

Major Changes
-------------

Minor Changes
-------------
* Update README
* Fix lint errors
* Handlers listen to lowercase labels
* Split defaults in defaults/main/


2.6.1
=====

Release Summary
---------------
Ansible 2.17 update

Major Changes
-------------
- Support 13.3, 14.0, 14.1
- Update ansible-lint config.

Minor Changes
-------------
- Update python 3.11 in .travis.yml
- Format meta/main.yml
- selectattr in loops.
- Update README. Upgrade configuration to a new release.
- Update ezjail-flavours in blocks. selectattr in loops.
- Update tests/test.yml playbook

Bufixes
-------

Breaking Changes / Porting Guide
--------------------------------


2.6.0
=====

Release Summary
---------------
Update to Ansible 2.16. Support 12.4, 13.3, and 14.0

Major Changes
-------------
* Update meta
* Update README
* Add ports-mgmt/portsnap to bsd_jail_packages

Minor Changes
-------------
* Update contrib/jail-flavours to Python 3.9 and Perl 5.36

Bufixes
-------

Breaking Changes / Porting Guide
--------------------------------
