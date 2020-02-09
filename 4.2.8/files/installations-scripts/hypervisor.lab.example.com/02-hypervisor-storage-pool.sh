#!/bin/bash
mkdir /mnt/ocp_images
mkdir /mnt/ocp_isos
virsh pool-define-as ocp_images dir - - - - "/mnt/ocp_images"
virsh pool-define-as ocp_isos dir - - - - "/mnt/ocp_isos"
virsh pool-build ocp_images
virsh pool-build ocp_isos
virsh pool-start ocp_images
virsh pool-start ocp_isos
virsh pool-autostart ocp_images
virsh pool-autostart ocp_isos
qemu-img create -f qcow2 /mnt/ocp_images/services.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/workstation.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/bootstrap.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/master01.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/master02.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/master03.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/worker01.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/worker02.qcow2 50G
qemu-img create -f qcow2 /mnt/ocp_images/worker03.qcow2 50G
