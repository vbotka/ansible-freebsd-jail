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
