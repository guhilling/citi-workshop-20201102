# Chapter1:

# Installation of Openshift 4 UPI on KVM/libvirt

## Preparation of the installation environment

### Preface:

In this first chapter of this Openshift 4 Workstop we will guide you step by step on how to install Openshift 4.2 on an KVM libvirt based environment headless like (Redhat 8) or on an Fedora 31 or Redhat 8 Workstation.

> Important: This Environment can be installed as described on any other Linux distribution that has KVM/libvirtd installed an running.

Before we begin to prepare our environment for installing Openshift, we need some pre steps we need to walk through.

## Prerequisites:

- RHNID

- A Valid Red Hat openshift subscription

- GitHub account

- Red Hat 8 or Fedora 31 server / workstation with libvirt/KVM installed.

> In this Workshop we will show up the xml files for KVM/libvirt. If you want to use an graphical tool for setup your virtual Environment you can use virt-manager or cockpit or at least the virsh console.

## Environment:

The following virtual instances needs to be created to install the Openshift cluster:

| Amount: | OS:                 | RAM: | CPU: | Usage:                                               |
| ------- | ------------------- | ---- | ---- | ---------------------------------------------------- |
| 1       | Redhat Enterprise 8 | 4    | 2    | installation service machine                         |
| 1       | PXE Booted          | 6    | 2    | installation bootstrap node                          |
| 1       | PXE Booted          | 8    | 2    | master01                                             |
| 1       | PXE Booted          | 8    | 2    | master02                                             |
| 1       | PXE Booted          | 8    | 2    | master03                                             |
| 1       | PXE Booted          | 8    | 2    | worker01                                             |
| 1       | PXE Booted          | 8    | 2    | worker02                                             |
| 1       | PXE Booted          | 8    | 2    | worker03  and worker 04 ( will be provisioned later) |

Each node should have at least 50 GB of virtual disk space.

First of all your virtualisation host needs the proper packages for KVM/libvirtd and cockpit installed.

```
yum groupinstall "Virtualization Host" -y
```

```
yum install git rsync cockpit cockpit-ws cockpit-dashboard cockpit-machines cockpit-system cockpit-storaged virt-install bash-completion  -y
```

```
systemctl enable cockpit.socket
```

```
systemctl enable libvirtd --now
```

## Clone git repo:

From the root directory execute:

```
git clone git@gitlab.com:dirkdavidis/openshift-4-gls-workshop.git
```

## Create Storage pool:

First of all we need to create two storage pools. A storage pool is the location where we save our qcow2 images and iso images. We need approx 400GB free space for setting up our Openshift cluster. If the space in /var/lib/libvirt/ is not enough we can create additional storage pools on other hard discs.

To create a new storage pool please type in:

```
mkdir /mnt/ocp_images
```

```
mkdir /mnt/ocp_isos
```

```
virsh pool-define-as ocp_images dir - - - - "/mnt/ocp_images"
```

```
virsh pool-define-as ocp_isos dir - - - - "/mnt/ocp_isos"
```

This command will create the image pools.

Now we need to verify the storage pool object:

```
virsh pool-list --all
Name                 State      Autostart
-----------------------------------------
ocp_images           inactive   no
ocp_isos             inactive   no
```

Now we need to build storage based storage pool for the directory:

```
 virsh pool-build ocp_images
```

```
virsh pool-build ocp_isos
```

As for now the two storage pools are not active, to activate them and autostart them we need to start them:

```
virsh pool-start ocp_images
```

```
virsh pool-start ocp_isos
```

```
 virsh pool-list --all
 Name State Autostart
-----------------------------------------
default active yes
ocp_images active no
ocp_isos active no
```

The last step is to autostart the storage pools upon reboot:

```
virsh pool-autostart ocp_images
```

```
virsh pool-autostart ocp_isos
```

```
 virsh pool-info ocp_images
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
virsh pool-info ocp_isos
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

After we have done this we can copy our iso image of rhel 8 to the iso storage pool and we can create inside the storage pool directory on our server or workstation with the command below the qcow2 images for our virtual machines.

> Important: We need at least for each virtual machine 50GB Space 400 GB space is needed.

## RHEL ISO:

Before we start our installation we need to ensure that we have downloaded rhel-8.1-x86_64-dvd.iso to /mnt/ocp_isos/rhel-8.1-x86_64-dvd.iso. In our Workshop this has already been done. If you are doing this on your own download the rhel 8.1 iso from RedHat and place it in our ocp_isos directory. If you rename the iso file adjust the virt-install.sh for services machine and workstation accordingly

## Create VM Disk:

To create the disk use this command in the directory of the images storage pool:

```
qemu-img create -f qcow2 NAMEOFMACHINE.qcow2 50G
```

For the environment an virtual network is needed.

This network needs to be a NAT network with no DHCP activated. The DHCP server will be installed later on the services node.

Please choose your domain name e.g. lab.example.com and a proper IP adress range. This range should not be outside your KVM Host available.

The easiest way to create the environment on headless machines is to use the cockpit environment.

We can use the XML File below to create the needed KVM/libvirtd network for our Openshift 4 installation.

First copy the content *below* and place it in an ocp4-network.xml file on your KVM host:

```
vim /root/ocp4-network.xml
```

Save the ocp4-network.xml file. Then type the following commands in the order provided below:

```
virsh net-define /root/openshift-4-gls-workshop/4.2.8/files/virt-host-configuration/ocp4-network.xml
virsh net-start ocp4-network
virsh net-autostart ocp4-network
```

> **NOTE:** with this command, the network is persistently created, active and autostarted.

### OCP4 NETWORK XML:

```
<network>
  <name>ocp4-network</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <mac address='52:54:00:b7:7d:56'/>
  <domain name='lab.example.com'/>
  <ip address='192.168.100.1' netmask='255.255.255.0'>
  </ip>
</network>
```

After we have created the network we should now create our virtual machines.

## Create our virtual machines:

XML example of worker01.lab.example.com vm:

```
-->

<domain type='kvm'>
  <name>worker01.lab.example.com</name>
  <uuid>6124eff0-719f-4367-98d6-cebe1ac134c8</uuid>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://redhat.com/rhel/8-unknown"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory unit='KiB'>8388608</memory>
  <currentMemory unit='KiB'>8388608</currentMemory>
  <vcpu placement='static'>4</vcpu>
  <os>
    <type arch='x86_64' machine='pc-q35-4.1'>hvm</type>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <vmport state='off'/>
  </features>
  <cpu mode='host-model' check='partial'>
    <model fallback='allow'/>
  </cpu>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/mnt/data/Virtualisierung/KVM/VM-OCP4-IMAGES/worker01.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'>
      <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
    </controller>
    <controller type='sata' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pcie-root'/>
    <controller type='pci' index='1' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='1' port='0x10'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
    </controller>
    <controller type='pci' index='2' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='2' port='0x11'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
    </controller>
    <controller type='pci' index='3' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='3' port='0x12'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
    </controller>
    <controller type='pci' index='4' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='4' port='0x13'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
    </controller>
    <controller type='pci' index='5' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='5' port='0x14'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x4'/>
    </controller>
    <controller type='pci' index='6' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='6' port='0x15'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x5'/>
    </controller>
    <controller type='pci' index='7' model='pcie-root-port'>
      <model name='pcie-root-port'/>
      <target chassis='7' port='0x16'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x6'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:9f:95:87'/>
      <source network='ocp4-network'/>
      <model type='virtio'/>
      <boot order='2'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target type='isa-serial' port='0'>
        <model name='isa-serial'/>
      </target>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='unix'>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='2'/>
    </channel>
    <input type='tablet' bus='usb'>
      <address type='usb' bus='0' port='1'/>
    </input>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice' autoport='yes'>
      <listen type='address'/>
      <image compression='off'/>
    </graphics>
    <sound model='ich9'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x1b' function='0x0'/>
    </sound>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x0'/>
    </video>
    <redirdev bus='usb' type='spicevmc'>
      <address type='usb' bus='0' port='2'/>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
      <address type='usb' bus='0' port='3'/>
    </redirdev>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
    </memballoon>
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
      <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
    </rng>
  </devices>
</domain>
```

We have created the virt-install tool, with this tool we can provide the base KVM definitions on an headless machine without graphics.

In the next listings we will create the virtual machines for the cluster and surrounding machines:

## New Virtual Machines:

### Services Virtual Machine:

```
/root/openshift-4-gls-workshop/4.2.8/files/installations-scripts/hypervisor.lab.example.com/04-hypervisor-virt-install-services.sh
```

Installation will run in the foreground. After completion you can login using root/redhat.
You can close the connection typing "^]".

### Workstation Virtual Machine:

```
/root/openshift-4-gls-workshop/4.2.8/files/installations-scripts/hypervisor.lab.example.com/05-hypervisor-virt-install-workstation.sh &
```

Installation will run in the background. Workstation is not needed for installation.

## Import already provisioned virtual machine images as new virtual machine:

If the services and workstation machines are already provisioned, then you just need to create them with:

### Services Virtual Machine:

```
virt-install -n services.lab.example.com --description "Services Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --disk path=/mnt/ocp_images/services.qcow2,bus=virtio,size=50 --graphics vnc,port=5910 --import --network network=ocp4-network
```

### Workstation Virtual Machine:

```
virt-install -n workstation.lab.example.com --description "Workstation Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --disk path=/mnt/ocp_images/workstation.qcow2,bus=virtio,size=50 --graphics vnc,port=5910 --import --network network=ocp4-network,mac=52:54:00:af:bb:59
```

### Services Virtual Machine:

Services Machine is configured as follows:

```
hostname: services.lab.example.com
ip address: 192.168.100.254
netmask:    255.255.255.0
gateway:    192.168.100.1
dns server: 192.168.100.1
```

### Workstation Virtual Machine:

Workstastion Machine is configured as follows:

```
hostname: workstation.lab.example.com
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

The creation of the virtual machines for the Openshift cluster is described below at the end of the installation chapter.

## Fix firewall settings:

Then we need to open ports in firewalld:

```
firewall-cmd --add-service={dhcp,tftp,http,https,dns} --permanent
firewall-cmd --add-port={6443/tcp,22623/tcp,8080/tcp} --permanent
firewall-cmd --reload
```

## Setup Bind Named DNS server:

After that we start with configuring the named DNS server:

Comment out the two lines below in /etc/named.conf:

```
#listen-on port 53 { 127.0.0.1; };
#listen-on-v6 port 53 { ::1; };
```

then we need to allow queries from the VM subnet:

```
allow-query     { localhost;192.168.100.0/24; };
```

after that we need to specify a forwarder for our dns server. this is by default the first ip in our vm network:

```
options { ...
forwarders { 192.168.100.1; };
```

After that we need to define a dns zone inside /etc/named.conf:

```
zone "lab.example.com" IN {
    type master;
    file "lab.example.com.db";
    allow-update { none; };
};
```

After defining this zone we need to create the zone file in: /var/named/lab.example.com.db

```
$TTL     1D
@        IN  SOA dns.ocp4.lab.example.com. root.lab.example.com. (
                       2019022400 ; serial
                       3h         ; refresh
                       15         ; retry
                       1w         ; expire
                       3h         ; minimum
                                                                             )
                  IN  NS  dns.ocp4.lab.example.com.
dns.ocp4            IN  A   192.168.100.254
services            IN CNAME dns.ocp4
workstation            IN  A   192.168.100.253
bootstrap.ocp4            IN  A   192.168.100.10
master01.ocp4            IN  A   192.168.100.21
master02.ocp4            IN  A   192.168.100.22
master03.ocp4            IN  A   192.168.100.23
etcd-0.ocp4            IN  A   192.168.100.21
etcd-1.ocp4            IN  A   192.168.100.22
etcd-2.ocp4            IN  A   192.168.100.23
api.ocp4               IN  A   192.168.100.254
api-int.ocp4           IN  A   192.168.100.254
*.apps.ocp4            IN  A   192.168.100.254
worker01.ocp4            IN  A   192.168.100.31
worker02.ocp4            IN  A   192.168.100.32
worker03.ocp4            IN  A   192.168.100.33
worker04.ocp4            IN  A   192.168.100.34
_etcd-server-ssl._tcp.ocp4    IN  SRV 0 10    2380 etcd-0.ocp4
_etcd-server-ssl._tcp.ocp4      IN      SRV     0 10    2380 etcd-1.ocp4
_etcd-server-ssl._tcp.ocp4      IN      SRV     0 10    2380 etcd-2.ocp4
```

> Please adjust these files to your needs or just take these files exactly as they are!!!

```
systemctl restart named
```

To test our DNS server we just execute:

```
dig @localhost -t srv _etcd-server-ssl._tcp.ocp4.lab.example.com
```

Now we need to change the DNS Resolution on Services Machine and Workstation Machine as well:

On both Machines type in:

```
nmcli connection show
NAME  UUID                                  TYPE      DEVICE
ens3  191bce9e-d55b-471a-a0fa-c6f060d2e144  ethernet  ens3
```

Now we need to modify the connection to use our new DNS Server on both Virtual Machines:

```
nmcli connection modify ens3  ipv4.dns "192.168.100.254"
```

After that:

```
nmcli connection reload
```

```
nmcli connection up ens3
```

We can test if our Resolution is correct with:

```
host bootstrap.ocp4.lab.example.com
```

The output should be:

```
bootstrap.ocp4.lab.example.com has address 192.168.100.10
```

When the resolution is not working just reboot your VM and after this it should work.

Now we can step forward.

## Setup DHCP Server:

We need to create / update the /etc/dhcp/dhcpd.conf:

```
ddns-update-style interim;
 ignore client-updates;
 authoritative;
 allow booting;
 allow bootp;
 allow unknown-clients;
 subnet 192.168.100.0 netmask 255.255.255.0 {
         range 192.168.100.10 192.168.100.100;
         option routers 192.168.100.1;
         option domain-name-servers 192.168.100.254;
         option ntp-servers time.unisza.edu.my;
         option domain-search "lab.example.com","ocp4.lab.example.com";
         filename "pxelinux.0";
         next-server 192.168.100.254;
         host bootstrap { hardware ethernet 52:54:00:e1:78:8a; fixed-address 192.168.100.10; option host-name "bootstrap"; }
         host master01 { hardware ethernet 52:54:00:f1:86:29; fixed-address 192.168.100.21; option host-name "master01"; }
         host master02 { hardware ethernet 52:54:00:af:63:f3; fixed-address 192.168.100.22; option host-name "master02"; }
         host master03 { hardware ethernet 52:54:00:a9:98:dd; fixed-address 192.168.100.23; option host-name "master03"; }
         host worker01 { hardware ethernet 52:54:00:9f:95:87; fixed-address 192.168.100.31; option host-name "worker01"; }
         host worker02 { hardware ethernet 52:54:00:c4:8f:50; fixed-address 192.168.100.32; option host-name "worker02"; }
         host worker03 { hardware ethernet 52:54:00:fe:e5:e3; fixed-address 192.168.100.33; option host-name "worker03"; }
         host workstation { hardware ethernet 52:54:00:af:bb:59; fixed-address 192.168.100.253; option host-name "workstation"; }
         host worker04 { hardware ethernet 52:54:00:f1:79:58; fixed-address 192.168.100.34; option host-name "worker04"; }
}
```

> Important notice: Please adjust this file as per your environment
> 
> Please ensure that the MAC addresses matches exactly the MAC adresses of the virtual machines we created earlier

## Setup TFTP:

first we need to populate the default file for tftpboot:

```
mkdir -p  /var/lib/tftpboot/pxelinux.cfg
```

then we need to create the default file with the following content:

```
vim /var/lib/tftpboot/pxelinux.cfg/default
```

```
default menu.c32
prompt 0
timeout 30
menu title **** OpenShift 4 PXE Boot Menu ****

label bootstrap
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/bootstrap.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img

label master
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/master.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img

label worker
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/worker.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img
```

> Important: Please adjust the IP address to the ip address of your environment

Due to the matter of fact, that we are working in an headless environment, we need to ensure, that the vm's are automatically choose the correct image and ignitonfile for installation. To do so, we need to create 7 files in /var/lib/tftpboot/pxelinux.cfg, with slightly different content:

These files are named by the MAC address for each vm. for example the MAC address of the bootstrap node is:

```
52:54:00:e1:78:8a
```

Then our file needs to be:

```
01-52-54-00-e1-78-8a
```

The content of the file should be:

Bootstrap PXE configuration:

```
default bootstrap
prompt 0
timeout 30
label bootstrap
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/bootstrap.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img
```

The file for each master  node needs to be:

```
default master
prompt 0
timeout 30
label master
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/master.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img
```

The file for each worker node needs to be:

```
default worker
prompt 0
timeout 30
label worker
 kernel /openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.2.0/images/rhcos-4.2.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.2.0/ignitions/worker.ign initrd=/openshift4/4.2.0/rhcos-4.2.0-x86_64-installer-initramfs.img
```

> Each of the files we now create needs to have a 01- in front and then the MAC Address of each node seperated with a dash!!!

Now we need to copy syslinux for PXE boot:

```
cp -rvf /usr/share/syslinux/* /var/lib/tftpboot
```

After that start your TFTP server:

```
systemctl start tftp
```

## Configure Webserver to host Red Hat Core OS images:

First of all we need to change the configuration of the httpd from Listen on port 80 to Listen on Port 8080:

```
vim /etc/httpd/conf/httpd.conf
```

Search for the Line:

```
Listen 80
```

and turn it into:

```
Listen 8080
```

After that we restart httpd that our changes taking place:

```
systemctl restart httpd
```

Now we need to create a directory for hosting the kernel and initramfs for PXE boot:

```
mkdir -p /var/lib/tftpboot/openshift4/4.2.0/
```

access this directory:

```
cd /var/lib/tftpboot/openshift4/4.2.0/
```

and download the kernel file to this directory:

```
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-installer-kernel
```

Then the CoreOS Installer initramfs image:

```
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-installer-initramfs.img
```

Now we ned to relabel the files for selinux:

```
restorecon -RFv .
```

Next we need to host the Red Hat Core OS metal BIOS image:

```
mkdir -p /var/www/html/openshift4/4.2.0/images/
```

```
cd  /var/www/html/openshift4/4.2.0/images/
```

```
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/rhcos-4.2.0-x86_64-metal-bios.raw.gz
```

```
restorecon -RFv .
```

## Setup HAProxy as Loadbalancer:

We are going step by step to the end of our preparations. The last service we need to configure is the haproxy service.

Use the following code snippet and place it in /etc/haproxy. Please make a backup of your default haproxy.conf before.

```
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.default
```

```
vim /etc/haproxy/haproxy.cfg
```

/etc/haproxy/haproxy.cfg:

```
defaults
    timeout connect         5s
    timeout client          30s
    timeout server          30s
    log                     global

frontend kubernetes_api
    bind 0.0.0.0:6443
    default_backend kubernetes_api

backend kubernetes_api
    balance roundrobin
    option ssl-hello-chk
    server bootstap bootstrap.ocp4.lab.example.com:6443 check
    server master01 master01.ocp4.lab.example.com:6443 check
    server master02 master02.ocp4.lab.example.com:6443 check
    server master03 master03.ocp4.lab.example.com:6443 check

frontend machine_config
    bind 0.0.0.0:22623
    default_backend machine_config

backend machine_config
    balance roundrobin
    option ssl-hello-chk
    server bootstrap bootstrap.ocp4.lab.example.com:22623 check
    server master01 master01.ocp4.lab.example.com:22623 check
    server master02 master02.ocp4.lab.example.com:22623 check
    server master03 master03.ocp4.lab.example.com:22623 check

frontend router_https
    bind 0.0.0.0:443
    default_backend router_https

backend router_https
    balance roundrobin
    option ssl-hello-chk
    server worker01 worker01.ocp4.lab.example.com:443 check
    server worker02 worker02.ocp4.lab.example.com:443 check
    server worker03 worker03.ocp4.lab.example.com:443 check
    server worker04 worker04.ocp4.lab.example.com:443 check

frontend router_http
    mode http
    option httplog
    bind 0.0.0.0:80
    default_backend router_http

backend router_http
    mode http
    balance roundrobin
    server worker01 worker01.ocp4.lab.example.com:80 check
    server worker02 worker02.ocp4.lab.example.com:80 check
    server worker03 worker03.ocp4.lab.example.com:80 check
    server worker04 worker04.ocp4.lab.example.com:80 check
```

> Important: Please adjust this file according to your environment if needed.

Now we need to configure SElinux to use custom ports in SELinux:

```
semanage port  -a 22623 -t http_port_t -p tcp
semanage port  -a 6443 -t http_port_t -p tcp
semanage port  -a 32700 -t http_port_t -p tcp
```

Now we have created all of our services. the next step is to prepare the installation from the Openshift perspective

## Configure OpenShift installer and CLI binary:

From now on, unless otherwise stated, all steps will be performed on services.lab.example.com

We need to login with ssh and the username and password provided through the instructor:

```
ssh root@services.lab.example.com
```

First of all we need to download and install the Openshift client and the installer.

> Important: Please be sure that you downloaded the correct versions. If you have a version mismatch ???

```
cd /root

wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.8/openshift-install-linux-4.2.8.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.8/openshift-client-linux-4.2.8.tar.gz

tar -xvf openshift-install-linux-4.2.8.tar.gz
tar -xvf openshift-client-linux-4.2.8.tar.gz

cp -v oc kubectl openshift-install /usr/local/bin/
```

Now we need to create a SSH key pair to access to use later to access the CoreOS nodes

```
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
```

Next we need to create the ignition files that will be used during the installation:

```
cd /root
mkdir -p ocp4
cd ocp4
```

Now we need to create the install-config-base.yaml file:

```
apiVersion: v1
baseDomain: lab.example.com
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
metadata:
  name: ocp4
networking:
  clusterNetworks:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  none: {}
pullSecret: 'GET FROM cloud.redhat.com'
sshKey: 'SSH PUBLIC KEY'
```

Please adjust this file to your needs.

> The pull secret can be obtained after accessing: https://cloud.redhat.com
> 
> Please login with your RHNID and your password.
> 
> The pull secret can be found when access the following link:
> 
> https://cloud.redhat.com/openshift/install/metal/user-provisioned

To obtain this key please execute:

```
cat /root/.ssh/id_rsa.pub
```

Copy the content of the output into sshKey: Please don't forget the quotes at the beginning and the end.

Now we will create the ignition files:

```
cd /root/ocp4/
cp install-config-base.yaml install-config.yaml
```

Don't forget to copy this file this is very important!!! If this file is missing, then the creation of the ignition files will fail!!!

> Everytime you recreate the ignition files you need to ensure that the ocp4 directory is empty except the install-config-base.yaml file. Very Important the .openshift_install_state.json file needs to be deleted before you recreate the ignition file. This file contains the installation certificates and can damage your installation when you use old certificates in new ignition files.

```
openshift-install create ignition-configs
```

```
drwxr-xr-x. 3 root root     195 29. Nov 18:01 .
dr-xr-x---. 9 root root    4096 29. Nov 18:00 ..
drwxr-xr-x. 2 root root      50 29. Nov 18:01 auth
-rw-r--r--. 1 root root  288789 29. Nov 18:01 bootstrap.ign
-rw-r--r--. 1 root root    3716 24. Nov 23:58 install-config-base.yaml
-rw-r--r--. 1 root root    1825 29. Nov 18:01 master.ign
-rw-r--r--. 1 root root      96 29. Nov 18:01 metadata.json
-rw-r--r--. 1 root root   58088 29. Nov 18:01 .openshift_install.log
-rw-r--r--. 1 root root 1190917 29. Nov 18:01 .openshift_install_state.json
-rw-r--r--. 1 root root    1825 29. Nov 18:01 worker.ign
```

Now we need to copy the files to our httpd server:

```
mkdir -p /var/www/html/openshift4/4.2.0/ignitions
```

```
cp -v *.ign /var/www/html/openshift4/4.2.0/ignitions/
```

```
restorecon -RFv /var/www/html/
```

Now we are done with the installation and can start the initial cluster installation.

```
systemctl enable --now haproxy.service dhcpd httpd tftp named
```

> Important: ensure every time that haproxy is up and running. Sometimes during reboot of your service machine it is not coming up.

To ensure type:

```
systemctl status haproxy
```

If the state is failed then type:

```
systemctl restart haproxy
```

re-check again:

```
systemctl status haproxy
```

Now we are able to install our virtual machines.

We will define all of our initial virtual machines for the cluster with the following commands on the Hypervisor host:

### Bootstrap Virtual Machine:

```
virt-install -n bootstrap.lab.example.com --description "Bootstrap Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:e1:78:8a
```

### Master01 Virtual Machine:

```
virt-install -n master01.lab.example.com --description "Master01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:f1:86:29
```

### Master02 Virtual Machine:

```
virt-install -n master02.lab.example.com --description "Master02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:af:63:f3
```

### Master03 Virtual Machine:

```
virt-install -n master03.lab.example.com --description "Master03 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:a9:98:dd
```

### Worker01 Virtual Machine:

```
virt-install -n worker01.lab.example.com --description "Worker01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:9f:95:87
```

### Worker02 Virtual Machine:

```
virt-install -n worker02.lab.example.com --description "Worker02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:c4:8f:50
```

A good practice is to start bootstrap vm first. Then step by step all other machines. They will start and boot up and they will select the proper CoreOS Image and the ignition file automatically and install and reboot.

Sometimes it could happen, that after the first boot the machines are in a loop and always trying to boot again from pxe. This could happen it must not happen.

If it happens we need to do the following steps described below.

In our workshop the virtual machines are set to --noreboot. After the machines are powered up and the CoreOS installing is done it will not reboot. This is because all these nodes master, worker and bootstrap are in an headless mode.

So after 10 - 15 minutes we need to power off all of these nodes:

First we need to list all vm's:

```
virsh list --all
```

```
-    bootstrap.lab.example.com   running
-    services.lab.example.com    running
-    master01.lab.example.com    running
-    master02.lab.example.com    running
-    master03.lab.example.com    running
-    worker01.lab.example.com    running
-    worker02.lab.example.com    running
```

Now we need to poweroff all running machines:

```
virsh destroy bootstrap.lab.example.com ...
```

Our virtual machines are configured to boot always from pxe we now need to change this so that from now on they are booting from disc.

You can observe the installation process if you access the bootstrap node from your service machine with virsh command.

The first command gives us a list of boot devices and their order:

```
virsh dumpxml bootstrap.lab.example.com | grep 'boot order'
```

`2` is our virtual harddisk and `1` our nic.

```
<boot order='2'/>
<boot order='1'/>
```

Now we just need to change 2 into 1 and 1 into 2.

```
vim /etc/libvirt/qemu/bootstrap.lab.example.com.xml
```

Search for boot order and change it accordingly for all Openshift virtual machines.

After we made these changes we need to reload the xml files to libvirt. We are doing this with the command:

```
virsh define bootstrap.lab.example.com.xml
```

Now we can power on all our virtual machines with the command:

```
virsh start --domain bootstrap.lab.example.com
virsh start --domain master01.lab.example.com
virsh start --domain master02.lab.example.com
virsh start --domain master03.lab.example.com
virsh start --domain worker01.lab.example.com
virsh start --domain worker02.lab.example.com
```

You can observe the installation process if you access the bootstrap node from your service machine with the command:

```
ssh core@bootstrap.ocp4.lab.example.com
```

After done this there is during the installation process a way of executing a journalctl command to observe this process.

To check the cluster is up and running type in the following command:

```
export KUBECONFIG=/root/ocp4/auth/kubeconfig
```

```
oc whoami
```

```
oc get nodes
```

You should get an output of six machines in state Ready.

## Troubleshooting: Pending  Certificates

When you add machines to a cluster, two pending certificates signing request (CSRs) are generated for each machine that you added. You must verify that these CSRs are approved or, if necessary, approve them yourself.

```
oc get nodes
NAME      STATUS    ROLES   AGE  VERSION
master  Ready     master  63m  v1.14.6+c4799753c
master2  Ready     master  63m  v1.14.6+c4799753c
master3  Ready     master  64m  v1.14.6+c4799753c
worker1  NotReady  worker  76s  v1.14.6+c4799753c
worker2  NotReady  worker  70s  v1.14.6+c4799753c
...
```

The output lists all of the machines that we created.

Now we need to review the pending certificate signing requests (CSRs) and ensure that the you see a client and server request with `Pending` or `Approved` status for each machine that you added to the cluster:

```
oc get csr

NAME        AGE     REQUESTOR                                                                   CONDITION
csr-8b2br   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-8vnps   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-bfd72   5m26s   system:node:ip-10-0-50-126.us-east-2.compute.internal                       Pending
csr-c57lv   5m26s   system:node:ip-10-0-95-157.us-east-2.compute.internal                       Pending
```

> |
> Because the CSRs rotate automatically, approve your CSRs within an hour of adding the machines to the cluster. If you do not approve them within an hour, the certificates will rotate, and more than two certificates will be present for each node. You must approve all of these certificates. After you approve the initial CSRs, the subsequent node client CSRs are automatically approved by the cluster kube-controller-manager. You must implement a method of automatically approving the kubelet serving certificate requests.

Now we need to approve pending certificates:

```
oc adm certificate approve csr-bfd72
```

Tip:
To approve all pending certificates run the folloing command:

```
oc get csr -o name | xargs oc adm certificate approve
```

After that we can check the csr status again and validate that they are all "Approved,Issued":

```
oc get csr
```

## Intermediate Image Registry Storage Configuration

If the image-registry operator is not available after installation, we must configure storage for it. Instructions for both configuring a PersistentVolume, which is required for production clusters, and for configuring an empty directory as the storage location, which is available for only non-production clusters, are shown in this workshop. For now we just append dynamical storage to the registry.

First we check if we do not have a registry pod:

```
[root@services ~]# oc get pod -n openshift-image-registry
NAME                                              READY   STATUS    RESTARTS   AGE
cluster-image-registry-operator-56f5f56b8-ssjxj   2/2     Running   0          6m40s
```

If no pod is showin up, we need to patch the image registry operator with the following command:

```
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
```

Now we just a couple of minutes 1 -2 and then looking for the registry pods again:

```
[root@services ~]# oc get pod -n openshift-image-registry
NAME                                              READY   STATUS              RESTARTS   AGE
cluster-image-registry-operator-56f5f56b8-ssjxj   2/2     Running             0          8m34s
image-registry-57944b948b-42jvh                   0/1     ContainerCreating   0          6s
image-registry-64d649744c-bhn7k                   0/1     ContainerCreating   0          6s
node-ca-gn8v8                                     0/1     ContainerCreating   0          6s
node-ca-mzbwz                                     0/1     ContainerCreating   0          6s
node-ca-pxnwx                                     0/1     ContainerCreating   0          6s
node-ca-ql7s5                                     0/1     ContainerCreating   0          7s
node-ca-wql85                                     0/1     ContainerCreating   0          6s
```

The pods should now be up and running.

## Completing installation on User Provisioned Infrastructure:

After we complete the operator configuration, you can finish installing the cluster on infrastructure that you provide.

We need to confirm that all components are up and running.

```
 watch -n5 oc get clusteroperators
```

```
NAME                                 VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
authentication                       4.2.0     True        False         False      10m
cloud-credential                     4.2.0     True        False         False      22m
cluster-autoscaler                   4.2.0     True        False         False      21m
console                              4.2.0     True        False         False      10m
dns                                  4.2.0     True        False         False      21m
image-registry                       4.2.0     True        False         False      16m
ingress                              4.2.0     True        False         False      16m
kube-apiserver                       4.2.0     True        False         False      19m
kube-controller-manager              4.2.0     True        False         False      18m
kube-scheduler                       4.2.0     True        False         False      22m
machine-api                          4.2.0     True        False         False      22m
machine-config                       4.2.0     True        False         False      18m
marketplace                          4.2.0     True        False         False      18m
monitoring                           4.2.0     True        False         False      18m
network                              4.2.0     True        False         False      16m
node-tuning                          4.2.0     True        False         False      21m
openshift-apiserver                  4.2.0     True        False         False      21m
openshift-controller-manager         4.2.0     True        False         False      17m
openshift-samples                    4.2.0     True        False         False      14m
operator-lifecycle-manager           4.2.0     True        False         False      21m
operator-lifecycle-manager-catalog   4.2.0     True        False         False      21m
service-ca                           4.2.0     True        False         False      21m
service-catalog-apiserver            4.2.0     True        False         False      16m
service-catalog-controller-manager   4.2.0     True        False         False      16m
storage                              4.2.0     True        False         False      16m
```

  When all of the cluster Operators are available (the kube-apiserver operator is last in state PROGRESSING=True and takes roughly 15min to finish), we can complete the installation.

> The Ignition config files that the installation program generates contain certificates that expire after 24 hours. You must keep the cluster running for 24 hours in a non-degraded state to ensure that the first certificate rotation has finished.
