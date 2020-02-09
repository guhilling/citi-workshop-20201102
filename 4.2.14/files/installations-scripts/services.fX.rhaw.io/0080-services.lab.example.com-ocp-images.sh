#!/bin/bash
set -euo pipefail

mkdir -p /var/lib/tftpboot/openshift4/4.2.0/
cd /var/lib/tftpboot/openshift4/4.2.0/
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-installer-kernel
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-installer-initramfs.img
restorecon -RFv /var/lib/tftpboot/openshift4/4.2.0/
mkdir -p /var/www/html/openshift4/4.2.0/images/
cd  /var/www/html/openshift4/4.2.0/images/
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-metal-bios.raw.gz
restorecon -RFv /var/www/html/
mkdir /var/www/html/openshift4/4.2.0/ignitions
