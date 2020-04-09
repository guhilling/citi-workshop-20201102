#!/bin/bash
set -euo pipefail

mkdir -p  /var/lib/tftpboot/pxelinux.cfg
cp -pR ../../services.lab.example.com-configuration/tftpboot/pxelinux.cfg/* /var/lib/tftpboot/pxelinux.cfg/
cp -rvf /usr/share/syslinux/* /var/lib/tftpboot
systemctl start tftp
