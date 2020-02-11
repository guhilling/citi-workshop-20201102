#!/bin/bash
set -euo pipefail

cp /etc/named.conf{,.default}
cp -pR ../../services.h12.rhaw.io/named/etc/named.conf /etc/
cp -pR ../../services.h12.rhaw.io/named/var/named/h12.rhaw.io.db /var/named
systemctl restart named

