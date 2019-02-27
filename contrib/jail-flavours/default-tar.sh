#!/bin/sh
cd /root
gtar -cpf default.tar -T default-list.txt 
gtar -tvf default.tar
