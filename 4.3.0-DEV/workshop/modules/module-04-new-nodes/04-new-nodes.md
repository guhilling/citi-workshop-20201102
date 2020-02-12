## Adding new Node to Cluster:

An important task for operations is to adding new nodes to the cluster. The reason could me more workload on the cluster. Nodes for specific reasons (infrastructure nodes), nodes for specific purpouse (nodes for specific customers)

The procedure is quite similar to the installation process.

In our environment first we need to create a new virtual node:

worker 03

```
virt-install -n worker03.hX.rhaw.io --description "Worker03 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker03.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:fe:e5:e3
```

After we have done this, the node will power on and will be pxe booted. After that it will fetch the CoreOS image and the related ignition file and will start the installation.

The node will stop after installation and we need to start the node with the command:

```
virsh start --domain worker03.hX.rhaw.io
```

Now we need to do the same steps as in the cluster installation:

```
[root@hypervisor ~]# virsh list --all
```

```
Id    Name                           Status
----------------------------------------------------
 15    workstation.hX.rhaw.io    laufend
 18    services.hX.rhaw.io       laufend
 20    bootstrap.hX.rhaw.io      laufend
 22    master01.hX.rhaw.io       laufend
 24    master02.hX.rhaw.io       laufend
 27    master03.hX.rhaw.io       laufend
 29    worker01.hX.rhaw.io       laufend
 30    worker02.hX.rhaw.io       laufend
```

After the worker03 node has been installed we can't see it in the list of nodes:

```
[root@services ~]# oc get nodes
NAME       STATUS   ROLES           AGE    VERSION
master01   Ready    master,worker   24h    v1.16.2
master02   Ready    master,worker   24h    v1.16.2
master03   Ready    master,worker   24h    v1.16.2
worker01   Ready    worker          24h    v1.16.2
worker02   Ready    worker          24h    v1.16.2
```

When we look at the csr's in our cluster we can see that some are in pending mode. This is because of our new node. 

```
[root@services ~]# oc get csr
NAME        AGE     REQUESTOR                                                                   CONDITION
csr-66q24   48m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-9p5kh   2m47s   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-fl4f9   63m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-mbr5t   18m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-wkrsp   33m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
```

we have to approve all pending certificates:

```
oc get csr -o name | xargs oc adm certificate approve
```

We need a secound round:

```
[root@services ~]# oc get csr
```

```
NAME        AGE     REQUESTOR                                                                   CONDITION
csr-72t87   4s      system:node:worker03                                                        Pending
csr-f6tsc   20m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
csr-lrc8f   5m19s   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
```

And a last approvel:

```
oc adm certificate approve CERTIFICATE
```

After a couple of minutes the machine should be up and running and part of the cluster as a third worker node:

```
[root@services ~]# oc get nodes
NAME       STATUS   ROLES           AGE    VERSION
master01   Ready    master,worker   24h    v1.16.2
master02   Ready    master,worker   24h    v1.16.2
master03   Ready    master,worker   24h    v1.16.2
worker01   Ready    worker          24h    v1.16.2
worker02   Ready    worker          24h    v1.16.2
worker03   Ready    worker          113s   v1.16.2
```

For the next Step in our Workshop we will add another node to the cluster worker04.hX.rhaw.io:

```
virt-install -n worker04.hX.rhaw.io --description "Worker04 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker04.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:f1:79:58
```

After that we will just follow the steps we did with worker03.hX.rhaw.io.
