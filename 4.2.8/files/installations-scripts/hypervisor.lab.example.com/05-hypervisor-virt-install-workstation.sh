NAME=workstation.lab.example.com
DESCRIPTION="Workstation Machine for Openshift 4 Cluster"
RAM=8192
VCPUS=4
MAC=52:54:00:af:bb:59
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
	--graphics vnc \
	--network network=ocp4-network,mac=${MAC} \
	--location /mnt/ocp_isos/rhel-8.1-x86_64-dvd.iso \
	--initrd-inject=$(dirname $0)/${KICKSTART} \
	--extra-args "ks=file:/${KICKSTART} console=ttyS0,115200" \
	--boot useserial=on \
	--rng /dev/random

# Leave console with Ctrl+]
