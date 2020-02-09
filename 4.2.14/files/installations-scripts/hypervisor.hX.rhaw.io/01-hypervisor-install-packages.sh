#!/bin/bash
yum groupinstall "Virtualization Host" -y
yum install virt-install  bash-completion -y
systemctl enable libvirtd --now
systemctl enable firewalld --now
firewall-cmd --add-service={ssh,http,https} --permanent
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --reload
