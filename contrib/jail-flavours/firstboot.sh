#!/bin/sh
env ASSUME_ALWAYS_YES=YES pkg install sudo
env ASSUME_ALWAYS_YES=YES pkg install perl5
env ASSUME_ALWAYS_YES=YES pkg install python36
pw useradd -n admin -s /bin/sh -m
chown -R admin:admin /home/admin
chmod 0700 /home/admin/.ssh
chmod 0600 /home/admin/.ssh/authorized_keys
chown root:wheel /usr/local/etc/sudoers
echo "admin ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers
