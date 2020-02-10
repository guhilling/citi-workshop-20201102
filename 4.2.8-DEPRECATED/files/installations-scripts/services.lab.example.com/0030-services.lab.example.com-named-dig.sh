#!/bin/bash
set -euo pipefail

dig @localhost -t srv _etcd-server-ssl._tcp.ocp4.lab.example.com
