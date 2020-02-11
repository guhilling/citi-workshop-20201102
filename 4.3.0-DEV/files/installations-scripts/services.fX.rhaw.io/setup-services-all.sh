#!/bin/bash

#
# execute all services scripts
#

set -euo pipefail
for s in ????-services*.sh
do
	echo "Running ${s} ..."
	./${s}
	echo "Finished ${s}"
done
