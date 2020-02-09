#!/bin/bash

#
# execute all services scripts
#

set -euo pipefail
for s in ????-services.lab.example.com*.sh
do
	./$s
done
