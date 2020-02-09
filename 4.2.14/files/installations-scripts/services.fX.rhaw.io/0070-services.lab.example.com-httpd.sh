#!/bin/bash
set -euo pipefail

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.default
cp -pR ../../services.hX.rhaw.io-configuration/httpd/etc/conf/httpd.conf /etc/httpd/conf/
