#!/bin/bash
set -euo pipefail

cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.default
cp -pR ../../services.hX.rhaw.io-configuration/dhcpd/etc/dhcp/dhcpd.conf /etc/dhcp/

