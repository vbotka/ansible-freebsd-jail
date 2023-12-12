#!/bin/sh

# FreeBSD
gtar -cpf default.tar -C default -T default-list.txt
gtar -tvf default.tar

# Linux
# tar -cpf default.tar -C default -T default-list.txt
# tar -tvf default.tar
