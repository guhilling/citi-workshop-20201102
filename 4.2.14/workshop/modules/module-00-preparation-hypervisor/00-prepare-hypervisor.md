# Module 00:

## Preparation of the Hypervisor:

## Preface:

In this module of this Openshift 4 Workstop we will guide you step by step on how to prepare the Hypervisor on which we will later install Openshift 4.2 with KVM libvirt based environments like (Redhat 8) or on an Fedora 31 or Redhat 8 Workstation.

> Important: This Environment can be installed as described on any other Linux distribution that has KVM/libvirtd installed an running.

### Prerequisites:

- RHNID

- A Valid Red Hat openshift subscription

- GitHub account

- Red Hat 8 or Fedora 31 server / workstation with libvirt/KVM installed.

> In this Workshop we will show up the xml files for KVM/libvirt. If you want to use an graphical tool for setup your virtual Environment you can use virt-manager or cockpit or at least the virsh console.

### Environment:

The following virtual instances needs to be created to install the Openshift Cluster:

| Amount: | OS:                 | RAM: | CPU: | Usage:                                               |
| ------- | ------------------- | ---- | ---- | ---------------------------------------------------- |
| 1       | Redhat Enterprise 8 | 8    | 2    | installation service machine                         |
| 1       | PXE Booted          | 8    | 2    | installation bootstrap node                          |
| 1       | PXE Booted          | 8    | 2    | master01                                             |
| 1       | PXE Booted          | 8    | 2    | master02                                             |
| 1       | PXE Booted          | 8    | 2    | master03                                             |
| 1       | PXE Booted          | 8    | 2    | worker01                                             |
| 1       | PXE Booted          | 8    | 2    | worker02                                             |
| 1       | PXE Booted          | 8    | 2    | worker03  and worker 04 ( will be provisioned later) |

Each node should have at least 50 GB of virtual disk space.

First of all our Hypervisor host needs the proper packages for KVM/libvirtd and cockpit installed.

Please execute the following command on your Hypervisor Machine:

```
[root@hypervisor ~]# yum groupinstall "Virtualization Host" -y
```

```
[root@hypervisor ~]# yum install git rsync cockpit cockpit-ws cockpit-dashboard cockpit-machines cockpit-system cockpit-storaged virt-install bash-completion  -y
```

```
[root@hypervisor ~]# systemctl enable cockpit.socket
```

```
[root@hypervisor ~]# systemctl enable libvirtd --now
```

### Clone GIT Repository:

For later in this workshop we need to clone the git repository that contains the complete workshop material and usefull helper scripts and playbooks that makes live easier.

From the root directory on your hypervisor execute:

```
[root@hypervisor ~]# git clone git@gitlab.com:dirkdavidis/openshift-4-gls-workshop.git
```

On the Hypervisor in your root directory /root you will find now a openshift-4-gls-workshop directory. if you access this directory you will find a directory called: 4.2.14 this is the actual workshop version, it is based upon the release taken for this workshop.

### Create Storage pool:

First of all we need to create two storage pools. A storage pool is the location where we save our qcow2 images and iso images. We need approx 400GB free space for setting up our Openshift cluster. If the space in /var/lib/libvirt/ is not enough we can create additional storage pools on other hard discs. 

> Setting up and mounting additional harddisks is not covered in this workshop.

To create a new storage pool please type in on your hypervisor machine:

```
[root@hypervisor ~]# mkdir /mnt/ocp_images
```

```
[root@hypervisor ~]# mkdir /mnt/ocp_isos
```

```
[root@hypervisor ~]# virsh pool-define-as ocp_images dir - - - - "/mnt/ocp_images"
```

```
[root@hypervisor ~]# virsh pool-define-as ocp_isos dir - - - - "/mnt/ocp_isos"
```

This command will create the image pools.

Now we need to verify the storage pool object:

```
[root@hypervisor ~]# virsh pool-list --all
Name                 State      Autostart
-----------------------------------------
ocp_images           inactive   no
ocp_isos             inactive   no
```

Now we need to build storage based storage pool for the directory:

```
 [root@hypervisor ~]# virsh pool-build ocp_images
```

```
[root@hypervisor ~]# virsh pool-build ocp_isos
```

As for now the two storage pools are not active, to activate them and autostart them we need to start them:

```
[root@hypervisor ~]# virsh pool-start ocp_images
```

```
[root@hypervisor ~]# virsh pool-start ocp_isos
```

```
 [root@hypervisor ~]# virsh pool-list --all
 Name State Autostart
-----------------------------------------
default active yes
ocp_images active no
ocp_isos active no
```

The last step is to autostart the storage pools upon reboot:

```
[root@hypervisor ~]# virsh pool-autostart ocp_images
```

```
[root@hypervisor ~]# virsh pool-autostart ocp_isos
```

```
 [root@hypervisor ~]# virsh pool-info ocp_images
```

```
Name:           ocp_images
UUID:           40831c3d-e06e-416a-8655-a84a126ac185
Status:         laufend
Bleibend:       ja
Automatischer Start: ja
Kapazität:     847,08 GiB
Zuordnung:      10,04 GiB
Verfügbar:     837,03 GiB
```

```
[root@hypervisor ~]# virsh pool-info ocp_isos
```

```
Name:           ocp_isos
UUID:           650bea12-2d88-47b7-9a1e-91f04ace7771
Status:         laufend
Bleibend:       ja
Automatischer Start: ja
Kapazität:     847,08 GiB
Zuordnung:      10,04 GiB
Verfügbar:     837,03 GiB
```

After we have done this we can copy our iso image for rhel 8 to the iso storage pool and we can create inside the storage pool directory  our server or workstation with the command below the qcow2 images for our virtual machines.

> Important: We need at least for each virtual machine 50GB Space 400 GB space is needed.

### RHEL ISO:

Before we start our installation we need to ensure that we have downloaded rhel-8.1-x86_64-dvd.iso to /mnt/ocp_isos/rhel-8.1-x86_64-dvd.iso. In our Workshop this has already been done. If you are doing this on your own download the rhel 8.1 iso from RedHat and place it in our ocp_isos directory. If you rename the iso file adjust the virt-install.sh for services machine and workstation accordingly

### Create VM Disk:

To create the disk use this command in the directory of the images storage pool:

```
[root@hypervisor ~]# qemu-img create -f qcow2 NAMEOFMACHINE.qcow2 50G
```

For the environment an virtual network is needed.

This network needs to be a NAT network with no DHCP activated. The DHCP server will be installed later on the services node.

Please choose your domain name e.g. hX.rhaw.io and a proper IP adress range. This range should not be outside your KVM Host available.

The easiest way to create the environment on headless machines is to use the cockpit environment.

We can use the XML File below to create the needed KVM/libvirtd network for our Openshift 4 installation.

First copy the content *below* and place it in an ocp4-network.xml file on your KVM host:

```
[root@hypervisor ~]# vim /root/ocp4-network.xml
```

Save the ocp4-network.xml file. Then type the following commands in the order provided below:

```
[root@hypervisor ~]# virsh net-define /root/openshift-4-gls-workshop/4.2.14/files/virt-host-configuration/ocp4-network.xml
```

```
[root@hypervisor ~]# virsh net-start ocp4-network
```

```
[root@hypervisor ~]# virsh net-autostart ocp4-network
```

> **NOTE:** with this command, the network is persistently created, active and autostarted.

### OCP4 NETWORK XML:

```
<network>
  <name>ocp4-network</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:b7:7d:56'/>
  <domain name='hX.rhaw.io'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
  </ip>
</network>
```

After we have created the network we should now create our virtual machines.

## New Virtual Machines on Hypervisor:

To make things easier we can create the two virtual machines we need for later, with the commands below, this will create the two needed machines, install base software on them with kickstart.

### Services Virtual Machine:

```
[root@hypervisor ~]# /root/openshift-4-gls-workshop/4.2.14/files/installations-scripts/hypervisor.hX.rhaw.io/04-hypervisor-virt-install-services.sh
```

Installation will run in the foreground. After completion you can login using into the services machine with username: root and password redhat.
You can close the connection typing "^]".

The following listing show the kickstart parameters used by virt-install.

## services.hX.rhaw.io.ks

```
#version=RHEL8
ignoredisk --only-use=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel
# Use text install and not graphical
text
# Use CDROM installation media
cdrom
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=ens3 --gateway=192.168.100.1 --ip=192.168.100.254 --nameserver=192.168.100.1 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=services.hX.rhaw.io
repo --name="AppStream" --baseurl=file:///run/install/repo/AppStream
# Root password redhat
# python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
rootpw --iscrypted $6$LwMuSOzhl/mBzGx.$4vco9HD/QpJfbkYi33HU8Kg0gi0McxTHe0RPt1pRTMNh/k5MjNBNuXf.ZgGO5qsG5ZAJPXTfwtYJDk2JNHhpC/

# Do not run the Setup Agent on first boot
firstboot --disable
# Do not configure the X Window System
skipx
# System services
services --disabled="chronyd"
# System timezone
timezone Europe/Amsterdam --isUtc --nontp
# Student password student
user --groups=wheel --name=student --password=$6$SLIfZs.v77RUQvQv$muLteoaXizPSZVE4hVZyRtty2CDuvLU/z7all2D2AdP4BV4KBRCxtz4/lU10jWqZpq4soAO9d2Jmt3at2JPdS. --iscrypted --gecos="student"
reboot

%packages
@^base
rsync
kexec-tools
wget
git
bind
bind-utils
dhcp-server
tftp-server
syslinux
httpd
httpd-tools
haproxy
vim
policycoreutils-python-utils
tar
bash-completion
tmux
podman
jq
httpd-tools
nfs-utils
container-selinux
```

### Workstation Virtual Machine:

```
[root@hypervisor ~]# /root/openshift-4-gls-workshop/4.2.14/files/installations-scripts/hypervisor.hX.rhaw.io/05-hypervisor-virt-install-workstation.sh &
```

Installation will run in the background. Workstation is not needed for installation.

The following listing show the kickstart parameters used by virt-install.

## workstation.hX.rhaw.io.ks:

```

```

## Import already provisioned virtual machine images as new virtual machine:

If the services and workstation machines are already provisioned, then you just need to create them with:

### Services Virtual Machine:

```
[root@hypervisor ~]# virt-install -n services.hX.rhaw.io --description "Services Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --disk path=/mnt/ocp_images/services.qcow2,bus=virtio,size=50 --graphics vnc,port=5910 --import --network network=ocp4-network
```

### Workstation Virtual Machine:

```
[root@hypervisor ~]# virt-install -n workstation.hX.rhaw.io --description "Workstation Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --disk path=/mnt/ocp_images/workstation.qcow2,bus=virtio,size=50 --graphics vnc,port=5910 --import --network network=ocp4-network,mac=52:54:00:af:bb:59
```

### Services Virtual Machine:

Services Machine is configured as follows:

```
hostname: services.hX.rhaw.io
ip address: 192.168.100.254
netmask:    255.255.255.0
gateway:    192.168.100.1
dns server: 192.168.100.1
```

### Workstation Virtual Machine:

Workstastion Machine is configured as follows:

```
hostname: workstation.hX.rhaw.io
ip address: 192.168.100.253
netmask:    255.255.255.0
gateway:    192.168.100.1
dns server: 192.168.100.1
```

> Important: In this workshop the services and the workstation virtual machines are already provisioned. So there is no need to create them.

> In these examples we will create the virtual disks, with the virt-install command. This will consume the complete storage defined in the virt-install options. If we want to save space we need to create the virtual disks images before with the qemu command provided, and then change the virt-install command options from --disk path=PATH to --import=PATH.

> MAC ADRESSES: We predefine the mac addresses, so that they are matching our DHCP/PXE settings later when we create our virtual machines. If you dont have predefined mac addresses use the script below, copy the content of the code into a script with the name macgen.py and make it executable. Then copy the mac address at the end into virt-install mac=XX:XX:XX:XX:XX:XX and in the proper line in your dhcpd.conf

```
#!/usr/bin/python
from random import randint
def gen_mac_char():
  return hex((randint(0,16))).split('x')[1]
def gen_mac_pair():
  return ''.join([gen_mac_char(), gen_mac_char()])
def gen_last_half_mac(stem):
  return '-'.join([stem, gen_mac_pair(), gen_mac_pair(), gen_mac_pair()])
print(gen_last_half_mac('52-54-00'))
```

After we have done all the steps above we are ready to configure our services machine in the next module.
