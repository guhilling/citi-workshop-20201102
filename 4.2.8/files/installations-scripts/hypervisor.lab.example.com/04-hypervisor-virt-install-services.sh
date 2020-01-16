NAME=services.lab.example.com
DESCRIPTION="Services Machine for Openshift 4 Cluster"
RAM=8192
VCPUS=4
MAC=
KICKSTART=${NAME}.ks

# Remove: virsh destroy ${NAME} && virsh undefine --remove-all-storage ${NAME}

virt-install \
	--name ${NAME} \
	--description "${DESCRIPTION}" \
	--os-type Linux \
	--os-variant rhel7 \
	--ram ${RAM} \
	--vcpus ${VCPUS} \
	--cpu host \
	--accelerate \
	--disk pool=ocp_images,bus=scsi,size=50,sparse=yes \
	--controller scsi,model=virtio-scsi \
	--graphics none \
	--network network=ocp4-network \
	--location /mnt/ocp_isos/rhel-8.1-x86_64-dvd.iso \
	--initrd-inject=$(dirname $0)/${KICKSTART} \
	--extra-args "ks=file:/${KICKSTART} console=ttyS0,115200" \
	--boot useserial=on \
	--rng /dev/random

#	--network network=ocp4-network,mac=${MAC} \

# Leave console with Ctrl+]
