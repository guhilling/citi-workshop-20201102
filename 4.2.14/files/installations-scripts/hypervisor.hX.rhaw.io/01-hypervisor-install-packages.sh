#!/bin/bash
yum groupinstall "Virtualization Host" -y
yum install virt-install  bash-completion haproxy -y
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.default
systemctl enable libvirtd --now
systemctl enable firewalld --now
systemctl enable haprxy --now
firewall-cmd --add-service={ssh,http,https} --permanent
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --reload
