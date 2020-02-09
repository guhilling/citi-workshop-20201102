#!/bin/bash
set -euo pipefail

cp /etc/named.conf{,.default}
cp -pR ../../services.hX.rhaw.io-configuration/named/etc/named.conf /etc/
cp -pR ../../services.hX.rhaw.io-configuration/named/var/named/hX.rhaw.io.db /var/named
systemctl restart named

