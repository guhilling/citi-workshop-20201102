#!/bin/bash
echo "
<network>
  <name>ocp4-network</name>
  <uuid>92ba4a90-a6af-402b-97c5-490f8626b7ff</uuid>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:b7:7d:56'/>
  <domain name='lab.example.com'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
  </ip>
</network>
" > /root/ocp4-network.xml

virsh net-create /root/ocp4-network.xml
virsh net-define /root/ocp4-network.xml
virsh net-start ocp4-network
virsh net-autostart ocp4-network
