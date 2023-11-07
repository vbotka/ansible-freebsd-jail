=====================================
vbotka.freebsd_jail 2.4 Release Notes
=====================================

.. contents:: Topics


2.4.0
=====

Release Summary
---------------
Update meta Ansible 2.14; OS versions and License. Remove
.yamllint. Update defaults, vars, and contrib. Add tags. Update README
with more details.

Major Changes
-------------
* Update vars. Simplify the collection of objects. Create lists:
  bsd_jail_jails_absent_names, +bsd_jail_jails_present_names,
  bsd_jail_jails_absent, and bsd_jail_jails_present. Use them in the
  loop. Tasks fn/objects.yml removed.
* Jail attributes falvour, parameters, jail_conf, and ezjail_conf are
  optional.
* Jail attributes firstboot and firstboot_* are optional.
* Add tags jail_ezjail_flavours_*
* Tag always flush handlers.
* Contrib update jail-flavours
* Contrib jail-objects; Add playbook and template to create jail
  objects.
* Defaults commented. contrib/jail-flavours and
  contrib/jail-objects. Simplify paths.
* README; Update contrib jail-objects, jail-flavours, references.

Minor Changes
-------------
* Update contrib my-jail-admin.sh to 0.1.1 Rename
  functions. Formatting.
* Add configuration in jail.conf.d (experimental). Add variable
  bsd_jail_confd (default:false).
* README; update examples, add sections: jail-objects
* Formatting of ezjail-jails:create debug, install_command

Breaking Changes / Porting Guide
--------------------------------

Bufixes
-------
