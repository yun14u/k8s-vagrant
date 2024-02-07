#!/bin/bash
export HOST=`hostname`
export WORKER_IP="`grep $HOST /etc/hosts|grep -v local |awk '{print $1}'`"

envsubst < /var/tmp/netplan_template > /etc/netplan/50-vagrant.yaml
chmod 600 /etc/netplan/50-vagrant.yaml
/usr/sbin/netplan apply
