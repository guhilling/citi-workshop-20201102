#!/bin/bash
set -euo pipefail

systemctl enable --now haproxy.service dhcpd httpd tftp named
systemctl restart haproxy
