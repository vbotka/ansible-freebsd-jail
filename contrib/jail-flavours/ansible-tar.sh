#!/bin/sh

# FreeBSD
# gtar -cpf ansible.tar -C ansible -T ansible-list.txt 
# gtar -tvf ansible.tar

# Linux
tar -cpf ansible.tar -C ansible -T ansible-list.txt 
tar -tvf ansible.tar
