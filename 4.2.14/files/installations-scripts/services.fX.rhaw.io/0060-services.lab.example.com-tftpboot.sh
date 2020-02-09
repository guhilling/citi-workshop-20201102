#!/bin/bash
set -euo pipefail

mkdir -p  /var/lib/tftpboot/pxelinux.cfg
cp -pR ../../services.hX.rhaw.io-configuration/tftpboot/pxelinux.cfg/* /var/lib/tftpboot/pxelinux.cfg/
cp -rvf /usr/share/syslinux/* /var/lib/tftpboot
systemctl start tftp
