#!/bin/sh
cd /root
gtar -cpf ansible.tar -T ansible-list.txt 
gtar -tvf ansible.tar
