#!/bin/bash
set -euo pipefail

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.default
cp -pR ../../services.h12.rhaw.io/httpd/etc/conf/httpd.conf /etc/httpd/conf/
