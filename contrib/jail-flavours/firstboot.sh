#!/bin/sh

VERSION="1.0.0"
USERNAME="admin"

# Install packages
env ASSUME_ALWAYS_YES=YES pkg install security/sudo
env ASSUME_ALWAYS_YES=YES pkg install lang/perl5.32
env ASSUME_ALWAYS_YES=YES pkg install lang/python38
env ASSUME_ALWAYS_YES=YES pkg install security/py-openssl
env ASSUME_ALWAYS_YES=YES pkg install archivers/gtar

# Create user
if (! getent passwd ${USERNAME} > /dev/null); then
    if (pw useradd -n ${USERNAME} -s /bin/sh -m); then
	printf "[OK] user ${USERNAME} created\n"
    else
	printf "[ERR] can not create user ${USERNAME}\n"
    fi
else
    printf "[OK] user ${USERNAME} exists\n"
fi

# Create directories and files

# $HOME/.ssh
if [ ! -e /home/${USERNAME}/.ssh ]; then
    if (mkdir /home/${USERNAME}/.ssh); then
	printf "[OK] dir /home/${USERNAME}/.ssh created\n"
    else
	printf "[ERR] can not create dir /home/${USERNAME}/.ssh\n"
    fi
else
    printf "[OK] dir /home/${USERNAME}/.ssh exists\n"
fi
[ -e /home/${USERNAME}/.ssh ] && chmod 0700 /home/${USERNAME}/.ssh

# $HOME/.ssh/authorized_keys
[ ! -e /home/${USERNAME}/.ssh/authorized_keys ] && \
    touch /home/${USERNAME}/.ssh/authorized_keys
[ -e /home/${USERNAME}/.ssh/authorized_keys ] && \
    chmod 0600 /home/${USERNAME}/.ssh/authorized_keys
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Configure sudoers
cp /usr/local/etc/sudoers.dist /usr/local/etc/sudoers
chown root:wheel /usr/local/etc/sudoers
chmod 0440 /usr/local/etc/sudoers
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers

# Configure root
chown root:wheel /root/firstboot.sh

# Configure etc
chown root:wheel /etc/rc.conf
chmod 0644 /etc/rc.conf
chown root:wheel /etc/resolv.conf
chmod 0644 /etc/resolv.conf
if [ -e /etc/rc.d/ezjail.flavour.default ]; then
    chown root:wheel /etc/rc.d/ezjail.flavour.default
    chmod 0755 /etc/rc.d/ezjail.flavour.default
fi

# EOF
