#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-focal entry
sed -e '/^.*ubuntu-focal.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
192.168.68.241 ckamaster01
192.168.68.242 ckaworker01
#
#192.168.56.52 ckamaster01
#192.168.56.53 ckaworker01
#192.168.56.54 ckaworker02
#192.168.56.55 ckaworker03
EOF
