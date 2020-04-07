#!/bin/bash

# usage: serv.bash <NUMBER-OF-HYPERVISOR>

i=$1

hostnamectl set-hostname services.h${i}.rhaw.io
sed -i "s/h12/h${i}/g" /etc/dhcp/dhcpd.conf
sed -i "s/h12/h${i}/g" /etc/named.conf
mv /var/named/h12.rhaw.io.db /var/named/h${i}.rhaw.io.db
mv /var/named/h12.rhaw.io.reverse.db /var/named/h${i}.rhaw.io.reverse.db
sed -i "s/h12/h${i}/g" /var/named/h${i}.rhaw.io.db
sed -i "s/h12/h${i}/g" /var/named/h${i}.rhaw.io.reverse.db
echo "192.168.100.254 services.h${i}.rhaw.io services" > /etc/hosts

systemctl restart dhcpd
systemctl restart named
systemctl restart haproxy
