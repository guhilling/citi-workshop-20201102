#!/bin/bash

#
# execute all services scripts
#

set -euo pipefail
for s in ????-services.hX.rhaw.io*.sh
do
	./$s
done
