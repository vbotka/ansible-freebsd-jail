#!/bin/sh

# FreeBSD
# gtar -cpf default.tar -C ansible -T default-list.txt 
# gtar -tvf default.tar

# Linux
tar -cpf default.tar -C ansible -T default-list.txt 
tar -tvf default.tar
