#!/bin/bash
set -euo pipefail

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.default
cp -pR ../../services.lab.example.com-configuration/httpd/etc/conf/httpd.conf /etc/httpd/conf/
