#!/bin/bash
set -euo pipefail

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.default
cp -pR ../../services.h12.rhaw.io/dhcpd/etc/dhcp/dhcpd.conf /etc/dhcp/

