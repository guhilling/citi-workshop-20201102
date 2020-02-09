#!/bin/bash
set -euo pipefail

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.default
cp -pR ../../services.lab.example.com-configuration/dhcpd/etc/dhcp/dhcpd.conf /etc/dhcp/

