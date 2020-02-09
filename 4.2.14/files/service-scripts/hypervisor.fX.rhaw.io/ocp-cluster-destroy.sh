#!/bin/bash
virsh destroy bootstrap.hX.rhaw.io && virsh undefine bootstrap.hX.rhaw.io --remove-all-storage
virsh destroy master01.hX.rhaw.io && virsh undefine master01.hX.rhaw.io --remove-all-storage
virsh destroy master02.hX.rhaw.io && virsh undefine master02.hX.rhaw.io --remove-all-storage
virsh destroy master03.hX.rhaw.io && virsh undefine master03.hX.rhaw.io --remove-all-storage
virsh destroy worker01.hX.rhaw.io && virsh undefine worker01.hX.rhaw.io --remove-all-storage
virsh destroy worker02.hX.rhaw.io && virsh undefine worker02.hX.rhaw.io --remove-all-storage
virsh list --all
echo "when virsh list --all shows just workstation and services machine up and running and no other virtual machine, then your cluster is deleted and cleaned up"
