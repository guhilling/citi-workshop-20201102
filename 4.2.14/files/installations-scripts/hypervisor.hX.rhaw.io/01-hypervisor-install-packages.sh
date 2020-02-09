#!/bin/bash
yum groupinstall "Virtualization Host" -y
yum install cockpit cockpit-ws cockpit-dashboard cockpit-machines cockpit-system cockpit-storaged virt-install  bash-completion -y
systemctl enable cockpit --now
systemctl enable libvirtd --now
systemctl enable firewalld --now
firewall-cmd --add-port=9090/tcp --permanent
firewall-cmd --reload
