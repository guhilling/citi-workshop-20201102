## Adding new Node to Cluster:

An important task for operations is to adding new nodes to the cluster. The reason could me more workload on the cluster. Nodes for specific reasons (infrastructure nodes), nodes for specific purpouse (nodes for specific customers)

The procedure is quite similar to the installation process.

In our environment first we need to create a new virtual node:

worker 03

```
virt-install -n worker03.lab.example.com --description "Worker03 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker03.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:fe:e5:e3
```

After we have done this, the node will power on and will be pxe booted. After that he will fetch the CoreOS image and the related ignition file and will start the installation.

The Node will stop after installation and we need to start the node with the command:

```
virsh start --domain worker03.lab.example.com
```

Now we need to do the same steps as in the cluster installation:

```
[root@hypervisor ~]# virsh list --all
```

```
Id    Name                           Status
----------------------------------------------------
 15    workstation.lab.example.com    laufend
 18    services.lab.example.com       laufend
 20    bootstrap.lab.example.com      laufend
 22    master01.lab.example.com       laufend
 24    master02.lab.example.com       laufend
 27    master03.lab.example.com       laufend
 29    worker01.lab.example.com       laufend
 30    worker02.lab.example.com       laufend
```

After the worker03 node has been installed we can't see him in the list of nodes:

```
[root@services ~]# oc get nodes
```

```
NAME       STATUS   ROLES           AGE    VERSION
master01   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
master02   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
master03   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
worker01   Ready    worker          21h    v1.14.6+6ac6aa4b0
worker02   Ready    worker          21h    v1.14.6+6ac6aa4b0
```

When we look at the csr's in our cluster we can see that some are in pending mode. This is because of our new node. 

```
[root@services ~]# oc get csr
```

```
NAME        AGE     REQUESTOR                                                                   CONDITION
csr-f6tsc   18m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
csr-lrc8f   3m46s   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
```

we need to approve all pending certificates:

```
oc adm certificate approve CERTIFICATE
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
[root@services ~] oc get nodes
```

```

master01   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
master02   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
master03   Ready    master,worker   21h    v1.14.6+6ac6aa4b0
worker01   Ready    worker          21h    v1.14.6+6ac6aa4b0
worker02   Ready    worker          21h    v1.14.6+6ac6aa4b0
worker03   Ready    worker          174m   v1.14.6+6ac6aa4b0
```

For the next Step in our Workshop we will add another node to the cluster worker04.lab.example.com:

```
virt-install -n worker04.lab.example.com --description "Worker04 Machine for Openshift 4 Cluster" --os-type=Linux --os-variant=rhel7 --ram=8192 --vcpus=4 --noreboot --disk path=/mnt/ocp_images/worker04.qcow2,bus=virtio,size=50 --graphics none --pxe --network network=ocp4-network,mac=52:54:00:f1:79:58
```

After that we will just follow the steps we did with worker03.lab.example.com.
