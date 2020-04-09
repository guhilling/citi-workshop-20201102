#!/bin/bash
set -euo pipefail

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.8/openshift-install-linux-4.2.8.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.8/openshift-client-linux-4.2.8.tar.gz
tar -xvf openshift-install-linux-4.2.8.tar.gz
tar -xvf openshift-client-linux-4.2.8.tar.gz
cp -v {oc,kubectl,openshift-install} /usr/bin/
rm -Rf openshift-install-linux-4.2.8.tar.gz
rm -Rf openshift-client-linux-4.2.8.tar.gz
rm -Rf oc
rm -Rf kubectl
rm -Rf openshift-install
