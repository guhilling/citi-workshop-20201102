#!/bin/bash

# usage: hypervisor-config.sh <NUMMER-OF-HYPERVISOR> 

i=$1
hostnamectl set-hostname h${i}.rhaw.io
sed -i "s/CentOS-77-64-minimal/h${i}.rhaw.io h${i}/" /etc/hosts
echo "192.168.100.254 services.h${i}.rhaw.io services" >> /etc/hosts
/usr/local/sbin/ocp-cluster-destroy.sh
virsh destroy services.hX.rhaw.io
rm -Rf /mnt/ocp_images/*.qcow2
virsh destroy services.hX.rhaw.io
sed -i "s/hX/h${i}/g" /usr/local/sbin/ocp-build-start-cluster-vms.sh
sed -i "s/hX/h${i}/g" /usr/local/sbin/ocp-cluster-destroy.sh
sed -i "s/hX/h${i}/g" /etc/libvirt/qemu/networks/ocp4-network.xml
sed -i "s/hX/h${i}/g" /etc/libvirt/qemu/services.hX.rhaw.io.xml
mv /etc/libvirt/qemu/services.hX.rhaw.io.xml /etc/libvirt/qemu/services.h${i}.rhaw.io.xml
tar -xvf /root/services.hX.rhaw.io.qcow2.tar.gz -C /mnt/ocp_images/
mv /mnt/ocp_images/services.hX.rhaw.io.qcow2 /mnt/ocp_images/services.h${i}.rhaw.io.qcow2
systemctl restart libvirtd
virsh start --domain services.h${i}.rhaw.io