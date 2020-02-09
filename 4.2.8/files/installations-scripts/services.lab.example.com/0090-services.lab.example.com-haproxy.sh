#!/bin/bash
set -euo pipefail

cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.default
cp -pR ../../services.lab.example.com-configuration/haproxy/etc/haproxy/haproxy.cfg /etc/haproxy/
semanage port  -a 22623 -t http_port_t -p tcp
semanage port  -a 6443 -t http_port_t -p tcp
semanage port  -a 32700 -t http_port_t -p tcp
