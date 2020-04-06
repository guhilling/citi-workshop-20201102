# Module01:

# Preparation of the installation Environment

### Preface:

## Fix firewall settings:

The next steps will be done on services.hX.rhaw.io

First we need to open firewall ports on the services machine:

```
[root@services ~]# firewall-cmd --add-service={dhcp,tftp,http,https,dns} --permanent
```

```
[root@services ~]# firewall-cmd --add-port={6443/tcp,22623/tcp,8080/tcp} --permanent
```

```
[root@services ~]# firewall-cmd --reload
```

## Setup Bind Named DNS server:

After that we start with configuring the named DNS server:

Comment out the two lines below in /etc/named.conf:

```
[root@services ~]# vim /etc/named.conf
```

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
zone "hX.rhaw.io" IN {
    type master;
    file "hX.rhaw.io.db";
    allow-update { none; };
};
```

After defining this zone we need to create the zone file in: /var/named/hX.rhaw.io.db

```
[root@services ~]#  vim /var/named/hX.rhaw.io.db
```

```
$TTL     1D
@        IN  SOA dns.ocp4.hX.rhaw.io. root.hX.rhaw.io. (
                       2019022400 ; serial
                       3h         ; refresh
                       15         ; retry
                       1w         ; expire
                       3h         ; minimum
                                                                             )
                  IN  NS  dns.ocp4.hX.rhaw.io.
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
[root@services ~]# systemctl restart named
```

To test our DNS server we just execute:

```
[root@services ~]# dig @localhost -t srv _etcd-server-ssl._tcp.ocp4.hX.rhaw.io
```

Now we need to change the DNS Resolution on Services Machine and Workstation Machine as well:

On both Machines type in:

```
[root@services ~]# nmcli connection show
NAME  UUID                                  TYPE      DEVICE
ens3  191bce9e-d55b-471a-a0fa-c6f060d2e144  ethernet  ens3
```

Now we need to modify the connection to use our new DNS Server on both Virtual Machines:

```
[root@services ~]# nmcli connection modify ens3  ipv4.dns "192.168.100.254"
```

After that:

```
[root@services ~]# nmcli connection reload
```

```
[root@services ~]# nmcli connection up ens3
```

We can test if our Resolution is correct with:

```
[root@services ~]# host bootstrap.ocp4.hX.rhaw.io
```

The output should be:

```
bootstrap.ocp4.hX.rhaw.io has address 192.168.100.10
```

When the resolution is not working just reboot your VM and after this it should work.

Now we can step forward.

## Setup DHCP Server:

We need to create / update the /etc/dhcp/dhcpd.conf:

```
[root@services ~]# vim /etc/dhcp/dhcpd.conf
```

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
         option domain-search "hX.rhaw.io","ocp4.hX.rhaw.io";
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
[root@services ~]# mkdir -p  /var/lib/tftpboot/pxelinux.cfg
```

then we need to create the default file with the following content:

```
[root@services ~]# vim /var/lib/tftpboot/pxelinux.cfg/default
```

```
default menu.c32
prompt 0
timeout 30
menu title **** OpenShift 4.3 PXE Boot Menu ****

label bootstrap
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/bootstrap.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img

label master
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/master.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img

label worker
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/worker.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
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
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/bootstrap.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
```

The file for each master  node needs to be:

```
default master
prompt 0
timeout 30
label master
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/master.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
```

The file for each worker node needs to be:

```
default worker
prompt 0
timeout 30
label worker
 kernel /openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
 append ip=dhcp rd.neednet=1 coreos.inst.install_dev=vda console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.image_url=http://192.168.100.254:8080/openshift4/4.3.0/images/rhcos-4.3.0-x86_64-metal-bios.raw.gz coreos.inst.ignition_url=http://192.168.100.254:8080/openshift4/4.3.0/ignitions/worker.ign initrd=/openshift4/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
```

> Each of the files we now create needs to have a 01- in front and then the MAC Address of each node seperated with a dash!!!

Now we need to copy syslinux for PXE boot:

```
[root@services ~]# cp -rvf /usr/share/syslinux/* /var/lib/tftpboot
```

After that start your TFTP server:

```
[root@services ~]# systemctl start tftp
```

## Configure Webserver to host Red Hat Core OS images:

First of all we need to change the configuration of the httpd from Listen on port 80 to Listen on Port 8080:

```
[root@services ~]# vim /etc/httpd/conf/httpd.conf
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
[root@services ~]# systemctl restart httpd
```

Now we need to create a directory for hosting the kernel and initramfs for PXE boot:

```
[root@services ~]# mkdir -p /var/lib/tftpboot/openshift4/4.3.0/
```

access this directory:

```
[root@services ~]# cd /var/lib/tftpboot/openshift4/4.3.0/
```

and download the kernel file to this directory:

```
[root@services ~]# wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-installer-kernel
```

Then the CoreOS Installer initramfs image:

```
[root@services ~]# wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-installer-initramfs.img
```

Now we ned to relabel the files for selinux:

```
[root@services ~]# restorecon -RFv .
```

Next we need to host the Red Hat Core OS metal BIOS image:

```
[root@services ~]# mkdir -p /var/www/html/openshift4/4.3.0/images/
```

```
[root@services ~]# cd  /var/www/html/openshift4/4.3.0/images/
```

```
[root@services ~]# wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/4.3.0/rhcos-4.3.0-x86_64-metal.raw.gz
```

```
[root@services ~]# restorecon -RFv .
```

## Setup HAProxy as Loadbalancer:

We are going step by step to the end of our preparations. The last service we need to configure is the haproxy service.

Use the following code snippet and place it in /etc/haproxy. Please make a backup of your default haproxy.conf before.

```
[root@services ~]# cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.default
```

```
[root@services ~]# vim /etc/haproxy/haproxy.cfg
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
    server bootstap bootstrap.ocp4.hX.rhaw.io:6443 check
    server master01 master01.ocp4.hX.rhaw.io:6443 check
    server master02 master02.ocp4.hX.rhaw.io:6443 check
    server master03 master03.ocp4.hX.rhaw.io:6443 check

frontend machine_config
    bind 0.0.0.0:22623
    default_backend machine_config

backend machine_config
    balance roundrobin
    option ssl-hello-chk
    server bootstrap bootstrap.ocp4.hX.rhaw.io:22623 check
    server master01 master01.ocp4.hX.rhaw.io:22623 check
    server master02 master02.ocp4.hX.rhaw.io:22623 check
    server master03 master03.ocp4.hX.rhaw.io:22623 check

frontend router_https
    bind 0.0.0.0:443
    default_backend router_https

backend router_https
    balance roundrobin
    option ssl-hello-chk
    server worker01 worker01.ocp4.hX.rhaw.io:443 check
    server worker02 worker02.ocp4.hX.rhaw.io:443 check
    server worker03 worker03.ocp4.hX.rhaw.io:443 check
    server worker04 worker04.ocp4.hX.rhaw.io:443 check

frontend router_http
    mode http
    option httplog
    bind 0.0.0.0:80
    default_backend router_http

backend router_http
    mode http
    balance roundrobin
    server worker01 worker01.ocp4.hX.rhaw.io:80 check
    server worker02 worker02.ocp4.hX.rhaw.io:80 check
    server worker03 worker03.ocp4.hX.rhaw.io:80 check
    server worker04 worker04.ocp4.hX.rhaw.io:80 check
```

> Important: Please adjust this file according to your environment if needed.

Now we need to configure SElinux to use custom ports in SELinux:

```
[root@services ~]# semanage port  -a 22623 -t http_port_t -p tcp
```

```
[root@services ~]# semanage port -a 6443 -t http_port_t -p tcp
```

```
[root@services ~]# semanage port -a 32700 -t http_port_t -p tcp
```

Now we have created all of our services. the next step is to prepare the installation from the Openshift perspective

## Configure OpenShift installer and CLI binary:

From now on, unless otherwise stated, all steps will be performed on services.hX.rhaw.io

We need to login with ssh and the username and password provided through the instructor:

```
ssh root@services.hX.rhaw.io
```

First of all we need to download and install the Openshift client and the installer.

> Important: Please be sure that you downloaded the correct versions. If you have a version mismatch ???

```
[root@services ~]# cd /root
```

```
[root@services ~]# wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.0/openshift-install-linux-4.3.0.tar.gz
```

```
[root@services ~]# wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.3.0/openshift-client-linux-4.3.0.tar.gz
```

```
[root@services ~]# tar -xvf openshift-install-linux-4.3.0.tar.gz
```

```
[root@services ~]# tar -xvf openshift-client-linux-4.3.0.tar.gz
```

```
[root@services ~]# cp -v oc kubectl openshift-install /usr/local/bin/
```

Now we need to create a SSH key pair to access to use later to access the CoreOS nodes

```
[root@services ~]# ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
```

## Set up the ignition files

We have to create the ignition files they will be used for the installation:

First we start with the install-config-base.yaml file

```
[root@services ~]# vim install-config-base.yaml
```

```
apiVersion: v1
baseDomain: hX.rhaw.io
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
[root@services ~]# cat /root/.ssh/id_rsa.pub
```

Copy the content of the output into the sshKey parameter: Don't miss the quotes at the beginning and the end of the cpoied string!

Create the direcory ocp4

```
[root@services ~]# mkdir -p ocp4
```
And change into it

```
[root@services ocp4]# cd ocp4
```

Copy the install-config-base.yaml file into the ocp4 directory and rename it to install-config.yaml

```
[root@services ocp4]# cp ../install-config-base.yaml install-config.yaml
```

Don't forget to copy this file this is very important!!! If this file is missing, the creation of the ignition files will fail!

> Everytime you recreate the ignition files you need to ensure that the ocp4 directory is empty except the install-config-base.yaml file and the manifest files have to be recreated and modifyied. Very Important the .openshift_install_state.json file needs to be deleted before you recreate the ignition file. This file contains the installation certificates and can damage your installation when you use old certificates in new ignition files.


Because we want to prevent pods from being scheduled on the control plane machines (masters), we have to modifiy the `manifests/cluster-scheduler-02-config.yml` Kubernetes manifest file.

To create the Kubernetes manifest files run:

```
[root@services ocp4]# openshift-install create manifests
INFO Consuming Install Config from target directory 
WARNING Making control-plane schedulable by setting MastersSchedulable to true for Scheduler cluster settings
```

Directory content looks now like this (the install-config.yaml is gone!):

```
[root@services ocp4]# tree /root/ocp4
/root/ocp4
├── manifests
│   ├── 04-openshift-machine-config-operator.yaml
│   ├── cluster-config.yaml
│   ├── cluster-dns-02-config.yml
│   ├── cluster-infrastructure-02-config.yml
│   ├── cluster-ingress-02-config.yml
│   ├── cluster-network-01-crd.yml
│   ├── cluster-network-02-config.yml
│   ├── cluster-proxy-01-config.yaml
│   ├── cluster-scheduler-02-config.yml
│   ├── cvo-overrides.yaml
│   ├── etcd-ca-bundle-configmap.yaml
│   ├── etcd-client-secret.yaml
│   ├── etcd-host-service-endpoints.yaml
│   ├── etcd-host-service.yaml
│   ├── etcd-metric-client-secret.yaml
│   ├── etcd-metric-serving-ca-configmap.yaml
│   ├── etcd-metric-signer-secret.yaml
│   ├── etcd-namespace.yaml
│   ├── etcd-service.yaml
│   ├── etcd-serving-ca-configmap.yaml
│   ├── etcd-signer-secret.yaml
│   ├── kube-cloud-config.yaml
│   ├── kube-system-configmap-root-ca.yaml
│   ├── machine-config-server-tls-secret.yaml
│   └── openshift-config-secret-pull-secret.yaml
└── openshift
    ├── 99_kubeadmin-password-secret.yaml
    ├── 99_openshift-cluster-api_master-user-data-secret.yaml
    ├── 99_openshift-cluster-api_worker-user-data-secret.yaml
    ├── 99_openshift-machineconfig_99-master-ssh.yaml
    └── 99_openshift-machineconfig_99-worker-ssh.yaml

2 directories, 30 files
```

We have to set the value of the parameter `mastersSchedulable` from true to false

```
[root@services ocp4]# sed -i 's/true/false/' manifests/cluster-scheduler-02-config.yml
```

Now we will create the ignition files:

```
[root@services ocp4]# openshift-install create ignition-configs
INFO Consuming Install Config from target directory 
INFO Consuming Worker Machines from target directory 
INFO Consuming Master Machines from target directory 
INFO Consuming Openshift Manifests from target directory 
INFO Consuming Common Manifests from target directory 
```

The content of the directory ocp4 has now this content (the directoies openshift and manifests are gone!)

```
[root@services ocp4]# tree /root/ocp4
/root/ocp4
├── auth
│   ├── kubeadmin-password
│   └── kubeconfig
├── bootstrap.ign
├── master.ign
├── metadata.json
└── worker.ign

```

We have to copy the files to our httpd server:

```
[root@services ocp4]# mkdir -p /var/www/html/openshift4/4.3.0/ignitions
```

```
[root@services ocp4]# cp -v *.ign /var/www/html/openshift4/4.3.0/ignitions/
```
```
[root@services ocp4]# chmod 644 /var/www/html/4.3.0/ignitions/*.ign
```

```
[root@services ocp4]# restorecon -RFv /var/www/html/
```

We are done now with the installation preparation steps and can start the initial cluster installation.

```
[root@services ocp4]# systemctl enable --now haproxy.service dhcpd httpd tftp named
```

> Important: ensure every time that haproxy is up and running. Sometimes during reboot of your service machine it is not coming up.

To ensure type:

```
[root@services ocp4]# systemctl status haproxy
```

If the state is failed then type:

```
[root@services ocp4]# systemctl restart haproxy
```

Re-check again:

```
[root@services ocp4]# systemctl status haproxy
```

Now we are able to install an OpenShift 4 cluster onto our virtual machines.
