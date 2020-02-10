#!/bin/bash
virsh destroy bootstrap.lab.example.com && virsh undefine bootstrap.lab.example.com --remove-all-storage
virsh destroy master01.lab.example.com && virsh undefine master01.lab.example.com --remove-all-storage
virsh destroy master02.lab.example.com && virsh undefine master02.lab.example.com --remove-all-storage
virsh destroy master03.lab.example.com && virsh undefine master03.lab.example.com --remove-all-storage
virsh destroy worker01.lab.example.com && virsh undefine worker01.lab.example.com --remove-all-storage
virsh destroy worker02.lab.example.com && virsh undefine worker02.lab.example.com --remove-all-storage
virsh list --all
echo "when virsh list --all shows just workstation and services machine up and running and no other virtual machine, then your cluster is deleted and cleaned up"
