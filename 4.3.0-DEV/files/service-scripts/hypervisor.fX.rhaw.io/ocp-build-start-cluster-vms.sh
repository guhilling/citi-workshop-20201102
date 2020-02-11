#!/bin/bash
qemu-img create -f qcow2 /mnt/ocp_images/bootstrap.qcow2 50G
sleep 5
virt-install -n bootstrap.hX.rhaw.io --description "Bootstrap Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/bootstrap.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:e1:78:8a
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/master01.qcow2 50G
sleep 5
virt-install -n master01.hX.rhaw.io --description "Master01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/master01.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:f1:86:29
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/master02.qcow2 50G
sleep 5
virt-install -n master02.hX.rhaw.io --description "Master02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/master02.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:af:63:f3
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/master03.qcow2 50G
sleep 5
virt-install -n master03.hX.rhaw.io --description "Master03 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/master03.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:a9:98:dd
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/worker01.qcow2 50G
sleep 5
virt-install -n worker01.hX.rhaw.io --description "Worker01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker01.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:9f:95:87
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/worker02.qcow2 50G
sleep 5
virt-install -n worker02.hX.rhaw.io --description "Worker02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker02.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:c4:8f:50
sleep 5
qemu-img create -f qcow2 /mnt/ocp_images/worker03.qcow2 50G
sleep 5
virsh list --all
sleep 5
virsh start --domain bootstrap.hX.rhaw.io
virsh start --domain master01.hX.rhaw.io
virsh start --domain master02.hX.rhaw.io
virsh start --domain master03.hX.rhaw.io
virsh start --domain worker01.hX.rhaw.io
virsh start --domain worker02.hX.rhaw.io
sleep 5
echo " all virtual machines have been created and started. the installation will take 30 minutes. you can watch the progress while ssh to bootstrap node with: ssh core@192.168.100.10 and follow the instructions"
