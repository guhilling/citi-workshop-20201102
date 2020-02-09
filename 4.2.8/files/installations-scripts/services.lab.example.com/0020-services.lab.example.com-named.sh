#!/bin/bash
set -euo pipefail

cp /etc/named.conf{,.default}
cp -pR ../../services.lab.example.com-configuration/named/etc/named.conf /etc/
cp -pR ../../services.lab.example.com-configuration/named/var/named/lab.example.com.db /var/named
systemctl restart named

