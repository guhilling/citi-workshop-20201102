# Module01:

# Installation

We will define all of our initial virtual machines for the cluster with the following commands on the Hypervisor host:

### Bootstrap Virtual Machine:

```
[root@hypervisor ~]# virt-install -n bootstrap.lab.example.com --description "Bootstrap Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:e1:78:8a
```

### Master01 Virtual Machine:

```
[root@hypervisor ~]# virt-install -n master01.lab.example.com --description "Master01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:f1:86:29
```

### Master02 Virtual Machine:

```
[root@hypervisor ~]# virt-install -n master02.lab.example.com --description "Master02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:af:63:f3
```

### Master03 Virtual Machine:

```
[root@hypervisor ~]# virt-install -n master03.lab.example.com --description "Master03 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:a9:98:dd
```

### Worker01 Virtual Machine:

```
[root@hypervisor ~]# virt-install -n worker01.lab.example.com --description "Worker01 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:9f:95:87
```

### Worker02 Virtual Machine:

```
[root@hypervisor ~]# virt-install -n worker02.lab.example.com --description "Worker02 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk pool=ocp_images,bus=virtio,size=50 --graphics vnc --pxe --network network=ocp4-network,mac=52:54:00:c4:8f:50
```

A good practice is to start bootstrap vm first. Then step by step all other machines. They will start and boot up and they will select the proper CoreOS Image and the ignition file automatically and install and reboot.

Sometimes it could happen, that after the first boot the machines are in a loop and always trying to boot again from pxe. This could happen it must not happen.

If it happens we need to do the following steps described below.

In our workshop the virtual machines are set to --noreboot. After the machines are powered up and the CoreOS installing is done it will not reboot. This is because all these nodes master, worker and bootstrap are in an headless mode.

So after 10 - 15 minutes we need to power off all of these nodes:

First we need to list all vm's:

```
[root@hypervisor ~]# virsh list --all
```

```
-    bootstrap.lab.example.com   running-    services.lab.example.com    running-    master01.lab.example.com    running-    master02.lab.example.com    running-    master03.lab.example.com    running-    worker01.lab.example.com    running-    worker02.lab.example.com    running
```

Now we need to poweroff all running machines:

```
[root@hypervisor ~]# virsh destroy bootstrap.lab.example.com ...
```

Our virtual machines are configured to boot always from pxe we now need to change this so that from now on they are booting from disc.

You can observe the installation process if you access the bootstrap node from your service machine with virsh command.

The first command gives us a list of boot devices and their order:

```
[root@hypervisor ~]# virsh dumpxml bootstrap.lab.example.com | grep 'boot order'
```

`2` is our virtual harddisk and `1` our nic.

Now we just need to change 2 into 1 and 1 into 2.

```
vim /etc/libvirt/qemu/bootstrap.lab.example.com.xml
```

Search for boot order and change it accordingly for all Openshift virtual machines.

After we made these changes we need to reload the xml files to libvirt. We are doing this with the command:

```
[root@hypervisor ~]# virsh define bootstrap.lab.example.com.xml
```

Now we can power on all our virtual machines with the command:

```
[root@hypervisor ~]# virsh start --domain bootstrap.lab.example.com
```

```
[root@hypervisor ~]# virsh start --domain master01.lab.example.com
```

```
[root@hypervisor ~]# virsh start --domain master02.lab.example.com
```

```
[root@hypervisor ~]# virsh start --domain master03.lab.example.com
```

```
[root@hypervisor ~]# virsh start --domain worker01.lab.example.com
```

```
[root@hypervisor ~]# virsh start --domain worker02.lab.example.com
```

You can observe the installation process if you access the bootstrap node from your service machine with the command:

```
[root@hypervisor ~]# ssh core@bootstrap.ocp4.lab.example.com
```

After done this there is during the installation process a way of executing a journalctl command to observe this process.

To check the cluster is up and running type in the following command:

```
[root@services ~]# export KUBECONFIG=/root/ocp4/auth/kubeconfig
```

```
[root@services ~]# oc whoami
```

```
[root@services ~]# oc get nodes
```

You should get an output of six machines in state Ready.

## Troubleshooting: Pending Certificates

When you add machines to a cluster, two pending certificates signing request (CSRs) are generated for each machine that you added. You must verify that these CSRs are approved or, if necessary, approve them yourself.

```
[root@services ~]# oc get nodes
```

```
NAME      STATUS    ROLES   AGE  VERSIONmaster  Ready     master  63m  v1.14.6+c4799753cmaster2  Ready     master  63m  v1.14.6+c4799753cmaster3  Ready     master  64m  v1.14.6+c4799753cworker1  NotReady  worker  76s  v1.14.6+c4799753cworker2  NotReady  worker  70s  v1.14.6+c4799753c...
```

The output lists all of the machines that we created.

Now we need to review the pending certificate signing requests (CSRs) and ensure that the you see a client and server request with `Pending` or `Approved` status for each machine that you added to the cluster:

```
[root@services ~]# oc get csr
```

```
NAME        AGE     REQUESTOR                                                                   CONDITIONcsr-8b2br   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pendingcsr-8vnps   15m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pendingcsr-bfd72   5m26s   system:node:ip-10-0-50-126.us-east-2.compute.internal                       Pendingcsr-c57lv   5m26s   system:node:ip-10-0-95-157.us-east-2.compute.internal                       Pending
```

> |
> Because the CSRs rotate automatically, approve your CSRs within an hour of adding the machines to the cluster. If you do not approve them within an hour, the certificates will rotate, and more than two certificates will be present for each node. You must approve all of these certificates. After you approve the initial CSRs, the subsequent node client CSRs are automatically approved by the cluster kube-controller-manager. You must implement a method of automatically approving the kubelet serving certificate requests.

Now we need to approve pending certificates:

```
[root@services ~]# oc adm certificate approve csr-bfd72
```

Tip:
To approve all pending certificates run the folloing command:

```
[root@services ~]# oc get csr -o name | xargs oc adm certificate approve
```

After that we can check the csr status again and validate that they are all "Approved,Issued":

```
[root@services ~]# oc get csr
```

## Intermediate Image Registry Storage Configuration

If the image-registry operator is not available after installation, we must configure storage for it. Instructions for both configuring a PersistentVolume, which is required for production clusters, and for configuring an empty directory as the storage location, which is available for only non-production clusters, are shown in this workshop. For now we just append dynamical storage to the registry.

First we check if we do not have a registry pod:

```
[root@services ~]# oc get pod -n openshift-image-registry
```

```
NAME                                              READY   STATUS    RESTARTS   AGEcluster-image-registry-operator-56f5f56b8-ssjxj   2/2     Running   0          6m40s
```

If no pod is showin up, we need to patch the image registry operator with the following command:

```
[root@services ~]# oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'
```

Now we just a couple of minutes 1 -2 and then looking for the registry pods again:

```
[root@services ~]# oc get pod -n openshift-image-registry
```

```

NAME                                              READY   STATUS              RESTARTS   AGEcluster-image-registry-operator-56f5f56b8-ssjxj   2/2     Running             0          8m34simage-registry-57944b948b-42jvh                   0/1     ContainerCreating   0          6simage-registry-64d649744c-bhn7k                   0/1     ContainerCreating   0          6snode-ca-gn8v8                                     0/1     ContainerCreating   0          6snode-ca-mzbwz                                     0/1     ContainerCreating   0          6snode-ca-pxnwx                                     0/1     ContainerCreating   0          6snode-ca-ql7s5                                     0/1     ContainerCreating   0          7snode-ca-wql85                                     0/1     ContainerCreating   0          6s
```

The pods should now be up and running.

## Completing installation on User Provisioned Infrastructure:

After we complete the operator configuration, you can finish installing the cluster on infrastructure that you provide.

We need to confirm that all components are up and running.

```
 [root@services ~]# watch -n5 oc get clusteroperators
```

```
NAME                                 VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCEauthentication                       4.2.0     True        False         False      10mcloud-credential                     4.2.0     True        False         False      22mcluster-autoscaler                   4.2.0     True        False         False      21mconsole                              4.2.0     True        False         False      10mdns                                  4.2.0     True        False         False      21mimage-registry                       4.2.0     True        False         False      16mingress                              4.2.0     True        False         False      16mkube-apiserver                       4.2.0     True        False         False      19mkube-controller-manager              4.2.0     True        False         False      18mkube-scheduler                       4.2.0     True        False         False      22mmachine-api                          4.2.0     True        False         False      22mmachine-config                       4.2.0     True        False         False      18mmarketplace                          4.2.0     True        False         False      18mmonitoring                           4.2.0     True        False         False      18mnetwork                              4.2.0     True        False         False      16mnode-tuning                          4.2.0     True        False         False      21mopenshift-apiserver                  4.2.0     True        False         False      21mopenshift-controller-manager         4.2.0     True        False         False      17mopenshift-samples                    4.2.0     True        False         False      14moperator-lifecycle-manager           4.2.0     True        False         False      21moperator-lifecycle-manager-catalog   4.2.0     True        False         False      21mservice-ca                           4.2.0     True        False         False      21mservice-catalog-apiserver            4.2.0     True        False         False      16mservice-catalog-controller-manager   4.2.0     True        False         False      16mstorage                              4.2.0     True        False         False      16m
```

  When all of the cluster Operators are available (the kube-apiserver operator is last in state PROGRESSING=True and takes roughly 15min to finish), we can complete the installation.

> The Ignition config files that the installation program generates contain certificates that expire after 24 hours. You must keep the cluster running for 24 hours in a non-degraded state to ensure that the first certificate rotation has finished.
