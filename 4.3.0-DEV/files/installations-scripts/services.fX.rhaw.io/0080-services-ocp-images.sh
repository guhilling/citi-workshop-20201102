#!/bin/bash
set -euo pipefail

[ -e /var/lib/tftpboot/openshift4 ] && rm -rf /var/lib/tftpboot/openshift4
mkdir -p /var/lib/tftpboot/openshift4/4.3.0/
cd /var/lib/tftpboot/openshift4/4.3.0/
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
restorecon -RFv /var/lib/tftpboot/openshift4/4.3.0/
[ -e /var/www/html/openshift4 ] && rm -rf /var/www/html/openshift4
mkdir -p /var/www/html/openshift4/4.3.0/images/
cd  /var/www/html/openshift4/4.3.0/images/
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-metal.raw.gz
restorecon -RFv /var/www/html/
mkdir -p /var/www/html/openshift4/4.3.0/ignitions
