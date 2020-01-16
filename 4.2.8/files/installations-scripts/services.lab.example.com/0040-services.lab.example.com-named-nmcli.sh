#!/bin/bash
set -euo pipefail

nmcli connection modify ens3  ipv4.dns "192.168.100.254"
nmcli connection reload
nmcli connection up ens3
host bootstrap.ocp4.lab.example.com
