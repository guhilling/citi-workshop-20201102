#!/bin/bash
set -euo pipefail

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.0/openshift-install-linux-4.3.0.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.0/openshift-client-linux-4.3.0.tar.gz
tar -xvf openshift-install-linux-4.3.0.tar.gz
tar -xvf openshift-client-linux-4.3.0.tar.gz
cp -v {oc,kubectl,openshift-install} /usr/bin/
rm -Rf openshift-install-linux-4.3.0.tar.gz
rm -Rf openshift-client-linux-4.3.0.tar.gz
rm -Rf oc
rm -Rf kubectl
rm -Rf openshift-install
rm -Rf README.md
