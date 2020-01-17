# Chapter 03 - Storage

> DRAFT DRAFT DRAFT this chapter is work-in-progress

OpenShift Container Platform requires storage for certain internal components. These are

- Registry
- Monitoring (Prometheus and Prometheus Alert Manager)
- Aggregates Logging (ElasticSearch component of OpenShift's aggregated logging component stack)

In addition, applications may require and request persistent storage via Persistent Volume Claims (PVCs).
For a general introduction on persistent storage see the [Persistent storage overview](https://docs.openshift.com/container-platform/4.2/storage/understanding-persistent-storage.html) chapter of the product documentation.

Overall, persistent storage needs to be carefully selected based upon the requirements of the respective components using the storage. These requirements include

- type of storage (file, block or object storage)
- amount of storage
- non-functional aspects such as performance and capacity requirements
- etc.

## NFS Storage

In this course we will use NFS storage to satisfy the persistent storage requirements of the OpenShift internal components and demonstrate storage capabilities for applications.

> Note:
> 
> NFS storage is **NOT** a generic approach and 'fits every scenario' solution. NFS storage has deficiencies for certain scenarios.
> 
> We will use for simplicity in this course NFS storage.

### Setup of a local NFS Server

We will use our services machine to setup a NFS server for use with our cluster. This acts for demonstration purposes. In a real-world environment dedicated storage backend servers would be used.

For a basic NFS server setup, execute the following commands on the services VM as root:

```
rpm -q nfs-utils container-selinux  # verify that the necessary packages have been installed by the kickstart

systemctl enable --now nfs-server rpcbind

firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service={nfs3,mountd,rpc-bind} --permanent
firewall-cmd --reload

setsebool -P nfs_export_all_rw 1
```

We now create dedicated export directories for the storage of the OpenShift internal components and a series of directories for application PVs, and set permissions. Overall, we need shares for

- OpenShift Registry 
- OpenShift Monitoring (2 Shares for Prometheus and 3 Shares for Prometheus AlertManager)
- OpenShift Aggregated Logging
- OpenShift Metering (TODO)

```
mkdir -p /data/nfs/sys-vols/registry
mkdir -p /data/nfs/sys-vols/monitoring/p-0
mkdir -p /data/nfs/sys-vols/monitoring/p-1
mkdir -p /data/nfs/sys-vols/monitoring/a-0
mkdir -p /data/nfs/sys-vols/monitoring/a-1
mkdir -p /data/nfs/sys-vols/monitoring/a-2
mkdir -p /data/nfs/sys-vols/logging/es-1
mkdir -p /data/nfs/sys-vols/logging/es-2
mkdir -p /data/nfs/user-vols/pv{1..50}

chown -R nobody.nobody  /data/nfs
chmod -R 777 /data/nfs
```

Finally, create the exports and restart the NFS server service:

```
echo /data/nfs/sys-vols/registry *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-registry.exports
echo /data/nfs/sys-vols/monitoring/p-0 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-monitoring-pr-0.exports
echo /data/nfs/sys-vols/monitoring/p-1 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-monitoring-pr-1.exports
echo /data/nfs/sys-vols/monitoring/a-0 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-monitoring-am-0.exports
echo /data/nfs/sys-vols/monitoring/a-1 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-monitoring-am-1.exports
echo /data/nfs/sys-vols/monitoring/a-2 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-monitoring-am-2.exports
echo /data/nfs/sys-vols/logging/es-1 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-elastic-1.exports
echo /data/nfs/sys-vols/logging/es-2 *(rw,sync,no_wdelay,no_root_squash,insecure,fsid=0) >> /etc/exports.d/openshift-sysvols-elastic-2.exports
for pvnum in {1..50} ; do
  echo /data/nfs/user-vols/pv${pvnum} *(rw,root_squash) >> /etc/exports.d/openshift-uservols.exports
done

exportfs -rav

systemctl reload-or-restart nfs-server
```

### Testing access to the NFS Server

In this chapter, we will act as system:admin user and create PV and PVC,
just to make sure that our NFS setup principally works.

Create a file 'nfs-pv.yaml' on the services machine having the following content:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/nfs/user-vols/pv50
    server: services.lab.example.com
    readOnly: false
```

Create a file 'nfs-pvc.yaml' on the services machine having the following content:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  resources:
     requests:
       storage: 1Gi
```

Now, create the PV.

```
oc create -f nfs-pv.yaml
// ... output omitted ...
```

```
oc get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                             STORAGECLASS   REASON   AGE
nfs-pv          1Gi        RWX            Retain           Available
```

Create an example project and import the PVC. The PVC should get bound to the existing PV.

```
oc new-project pvctest
// ... output omitted ...

oc status
// ... we are in the pvctest project ...

oc create -f nfs-pvc.yaml
// ... output omitted ...

oc get pvc
NAME       STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test-pvc   Bound    nfs-pv   1Gi        RWX                           20h

oc get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                             STORAGECLASS   REASON   AGE
nfs-pv          1Gi        RWX            Retain           Bound       pvctest/test-pvc                                                          20h
```

TODO: clean-up the above created ressources

## Configuring persistent NFS storage for the Registry

Create a file 'registry-pv.yaml' having the following content and load it into the cluster using `oc create -f registry-pv.yaml`.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/nfs/sys-vols/registry
    server: services.lab.example.com
    readOnly: false
```

The storage for the registry is defined in the config of the registry operator.

Remove any existing storage definition. Remember we have modified during installation the registry to use 'emptyDir', i.e., ephemeral storage. The following command removes the storage definition:

```
oc patch configs.imageregistry.operator.openshift.io cluster --type json --patch '[{ "op": "remove", "path": "/spec/storage" }]'
```

Now add a persistent storage with a PVC storage definition.

```
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"pvc":{"claim":""}}}}'
```

Watch the output of

```
oc get clusteroperator image-registry
```

Once 'progressing' moves to 'false', the operator has updated the rolled-out registry, and a registry PVC has been created. That PVC should have been bound to the above created PV.

```
oc get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                             STORAGECLASS   REASON   AGE
registry-pv     100Gi      RWX            Retain           Bound       openshift-image-registry/image-registry-storage                           87m
```

## Configuring Persistent Storage for Monitoring

> TODO

See [Recommended configurable storage technology](https://docs.openshift.com/container-platform/4.2/scalability_and_performance/optimizing-storage.html#recommended-configurable-storage-technology_persistent-storage) for general storage type recommendations.

In this workshop we use NFS file storage for monitoring though this is not the recommended storage type. Recommended is block storage.

See as well [Monitoring - Configuring persistent storage](https://docs.openshift.com/container-platform/4.2/monitoring/cluster-monitoring/configuring-the-monitoring-stack.html#configuring-persistent-storage) for additional details on the configuration of persistent storage for Monitoring.

Check whether the cluster-monitoring-config ConfigMap object exists:

```
oc -n openshift-monitoring get configmap cluster-monitoring-config
```

If it does not exist, create it:

```
oc -n openshift-monitoring create configmap cluster-monitoring-config
```

Edit the created config map using `oc -n openshift-monitoring edit configmap cluster-monitoring-config ` and put the following data section

```
data:
  config.yaml: |
    prometheusK8s:
      volumeClaimTemplate:
        metadata:
          name: prometheus-pvc
        spec:
          resources:
            requests:
              storage: 10Gi
          selector:
            matchLabels:
              infrapvc: "prometheus"
    alertmanagerMain:
      volumeClaimTemplate:
        metadata:
          name: alertmanager-pvc
        spec:
          resources:
            requests:
              storage: 2Gi
          selector:
            matchLabels:
              infrapvc: "alertmanager"
```

Save the changes to the ConfigMap. The operator will now apply the changed configuration and rollout new pods. You can use e.g. `oc get pods` to look for the new pods getting created.

We now have to ensure, Persistent Volumes (PVs) are ready to be claimed by the Persistent Volume Claim (PVC) created by the configuration change. One PV for each replica is required. By default, Prometheus uses two replicas and Alertmanager uses three replicas, hence we need five PVs to support the entire monitoring stack.

Check the PVCs created by the configuration change.

```
[root@services ~]# oc get pvc -n openshift-monitoring
NAME                                   STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
alertmanager-pvc-alertmanager-main-0   Pending                                                     11s
alertmanager-pvc-alertmanager-main-1   Pending                                                     11s
alertmanager-pvc-alertmanager-main-2   Pending                                                     11s
prometheus-pvc-prometheus-k8s-0        Pending                                                     7s
prometheus-pvc-prometheus-k8s-1        Pending                                                     7s
```

There are 5 PVCs created which are yet missing the required PVs. We now prepare these PVs as NFS-backed PVs.

Inspect one of the PVCs:

```
oc get pvc prometheus-pvc-prometheus-k8s-0 -o yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  creationTimestamp: "2020-01-09T16:00:01Z"
  finalizers:
  - kubernetes.io/pvc-protection
  labels:
    app: prometheus
    prometheus: k8s
  name: prometheus-pvc-prometheus-k8s-0
  namespace: openshift-monitoring
  resourceVersion: "741271"
  selfLink: /api/v1/namespaces/openshift-monitoring/persistentvolumeclaims/prometheus-pvc-prometheus-k8s-0
  uid: 18001914-32f9-11ea-9b39-525400af63f3
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  selector:
    matchLabels:
      infrapvc: prometheus
  volumeMode: Filesystem
status:
  phase: Pending
```

You can see the PVCs use 'matchLabel' selectors, hence we have to prepare the PVs to have respective labels as well.

Create the PV YAML definitions.

Create two YAML files for the Prometheus PVs as follows, pointing to the NFS server and respective shares '.../monitoring/p-0' and '.../monitoring/p-1' as follows:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: monitoring-pv-0
  labels:
    infrapvc: prometheus
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/nfs/sys-vols/monitoring/p-0
    server: services.lab.example.com
    readOnly: false
```

Create three YAML files for the AlertManager PVs as follows, pointing to the NFS server and respective shares '.../monitoring/a-0' to '.../monitoring/a-2' as follows:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: monitoring-alertmgr-pv-0
  labels:
    infrapvc: alertmanager
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/nfs/sys-vols/monitoring/a-0
    server: services.lab.example.com
    readOnly: false
```

Remember to not only adjust the path on the NFS server but as well the PV name in the metadata section.

> Observe that the PVs for Prometheus and Alertmanager use label 'infrapvc' with respective values mathing the label selectors in the PVs.

Now import the PV using `oc create -f filename.yaml` for each of the PV files created.

Check the PVCs (or PVs respectively) in the system to ensure the PVCs get bound.

```
oc get pvc -n openshift-monitoring
NAME                                   STATUS   VOLUME                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
alertmanager-pvc-alertmanager-main-0   Bound    monitoring-alertmgr-pv-0   10Gi       RWO                           5h16m
alertmanager-pvc-alertmanager-main-1   Bound    monitoring-alertmgr-pv-1   10Gi       RWO                           5h16m
alertmanager-pvc-alertmanager-main-2   Bound    monitoring-alertmgr-pv-2   10Gi       RWO                           5h16m
prometheus-pvc-prometheus-k8s-0        Bound    monitoring-pv-0            10Gi       RWO                           5h16m
prometheus-pvc-prometheus-k8s-1        Bound    monitoring-pv-1            10Gi       RWO                           5h16m
```

## Configuring Persistent Storage for Logging

> TODO

To add persistent storage for Logging, i.e., to the ElasticSearch component of OpenShift Cluster Logging, we assume cluster logging is already installed with ephemaral storage as described earlier in this workshop.

Overall, we now could add the storage definition to the 'ClusterLogging' CRD created earlier, replacing the ephemeral storage definition.

To demonstrate the rollout of logging including persistent storage, we simply delete the installed cluster logging components and re-rollout using a new definition including the persistent storage.

### Remove installed Cluster Logging instance

Reference: [Product Documentation - Uninstalling Cluster Logging](https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-uninstall.html)

Use the following command to remove everything generated during the deployment.

```
oc delete clusterlogging instance -n openshift-logging
```

This will remove all pods, deplyoments, services, routes. Watch the removal ov objects using `oc get all -n openshift-logging`. Only the cluster operator will remain:

```
oc get all
NAME                                            READY   STATUS    RESTARTS   AGE
pod/cluster-logging-operator-5cb9bf8c7f-pfg6t   1/1     Running   1          2d4h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-logging-operator   1/1     1            1           2d4h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/cluster-logging-operator-5cb9bf8c7f   1         1         1       2d4h
```

There should not by any PVCs in namespace 'openshift-logging' yet (we did not create any so far), but for sake of completeness, delete the PVCs as well:

```
oc delete pvc --all -n openshift-logging
```

### Install Cluster Logging using Persistent Storage

We now install Cluster Logging again using the known steps, however we add persistent storage configuration to the CRD.

You can re-use the existing 'cust-resource-def-logging.yaml' file of the CRD and simply edit it. As previously, we rollout only 2 ElasticSearch replicas and configure ElasticSearch for a minimal memory requests (8GB rather than the default 16 GB) due to the available resources in our workshop environment.

```
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance" 
  namespace: "openshift-logging"
spec:
  managementState: "Managed"  
  logStore:
    type: "elasticsearch"  
    elasticsearch:
      nodeCount: 2
      storage:
        size: 20G
        storageClassName: ""
      redundancyPolicy: "SingleRedundancy"
      resources:
        limits:
          memory: "8Gi"
        requests:
          cpu: "1"
          memory: "8Gi"
  visualization:
    type: "kibana"  
    kibana:
      replicas: 1
  curation:
    type: "curator"  
    curator:
      schedule: "30 3 * * *"
  collection:
    logs:
      type: "fluentd"  
      fluentd: {}
```

> Note the only difference to the installation before is the change in the 'spec.logStore.elasticsearch.storage' definition.

Wait a few moments and look for the Operator to rollout route, services, deployments, and pods.

Note that now PVCs got created:

```
oc get pvc
NAME                                         STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
elasticsearch-elasticsearch-cdm-y9htwcau-1   Pending                                                     2m26s
elasticsearch-elasticsearch-cdm-y9htwcau-2   Pending                                                     2m26s
```

Create 2 PV definitions for the created PVCs and loading them using `oc create -f es-pv-1.yaml` (adjusting the following example of the first PV for the 2nd PV):

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: elasticsearch-pv-1
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/nfs/sys-vols/logging/es-1
    server: services.lab.example.com
    readOnly: false
```

After a few seconds, the PVCs should get bound:

```
oc get pvc
NAME                                         STATUS   VOLUME               CAPACITY   ACCESS MODES   STORAGECLASS   AGE
elasticsearch-elasticsearch-cdm-y9htwcau-1   Bound    elasticsearch-pv-1   20Gi       RWO                           3m34s
elasticsearch-elasticsearch-cdm-y9htwcau-2   Bound    elasticsearch-pv-2   20Gi       RWO                           3m34s
```

## Configuring Persistent Storage for Metering

> TODO

# ...... old old old old old - to be removed - Chapter 03 - NFS Storage

OpenShift Container Platform clusters can be provisioned with persistent storage using NFS. 
Persistent volumes (PVs) and persistent volume claims (PVCs) provide a convenient method for sharing 
a volume across a project. While the NFS-specific information contained in a PV definition could also 
be defined directly in a Pod definition, doing so does not create the volume as a distinct cluster resource, 
making the volume more susceptible to conflicts.

A Network File System (NFS) allows remote hosts to mount file systems over a network and interact with those 
file systems as though they are mounted locally. This enables system administrators to consolidate 
resources onto centralized servers on the network.

## Persistent Storage overview

Managing storage is a distinct problem from managing compute resources. OpenShift Container Platform uses the Kubernetes persistent volume (PV) framework to allow cluster administrators to provision persistent storage for a cluster. Developers can use persistent volume claims (PVCs) to request PV resources without having specific knowledge of the underlying storage infrastructure.

PVCs are specific to a project, and are created and used by developers as a means to use a PV. PV resources on their own are not scoped to any single project; they can be shared across the entire OpenShift Container Platform cluster and claimed from any project. After a PV is bound to a PVC, that PV can not then be bound to additional PVCs. This has the effect of scoping a bound PV to a single namespace, that of the binding project.

PVs are defined by a PersistentVolume API object, which represents a piece of existing storage in the cluster that was either statically provisioned by the cluster administrator or dynamically provisioned using a StorageClass object. It is a resource in the cluster just like a node is a cluster resource.

PVs are volume plug-ins like Volumes but have a lifecycle that is independent of any individual Pod that uses the PV. PV objects capture the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.

IMPORTANT
High availability of storage in the infrastructure is left to the underlying storage provider.

PVCs are defined by a PersistentVolumeClaim API object, which represents a request for storage by a developer. It is similar to a Pod in that Pods consume node resources and PVCs consume PV resources. For example, Pods can request specific levels of resources, such as CPU and memory, while PVCs can request specific storage capacity and access modes. For example, they can be mounted once read-write or many times read-only.

## Storage lifecycle

Lifecycle of a volume and claim
PVs are resources in the cluster. PVCs are requests for those resources and also act as claim checks to the resource. The interaction between PVs and PVCs have the following lifecycle.

In response to requests from a developer defined in a PVC, a cluster administrator configures one or more dynamic provisioners that provision storage and a matching PV.

Alternatively, a cluster administrator can create a number of PVs in advance that carry the details of the real storage that is available for use. PVs exist in the API and are available for use.

When you create a PVC, you request a specific amount of storage, specify the required access mode, and create a storage class to describe and classify the storage. The control loop in the master watches for new PVCs and binds the new PVC to an appropriate PV. If an appropriate PV does not exist, a provisioner for the storage class creates one.

The size of all PVs might exceed your PVC size. This is especially true with manually provisioned PVs. To minimize the excess, OpenShift Container Platform binds to the smallest PV that matches all other criteria.

Claims remain unbound indefinitely if a matching volume does not exist or can not be created with any available provisioner servicing a storage class. Claims are bound as matching volumes become available. For example, a cluster with many manually provisioned 50Gi volumes would not match a PVC requesting 100Gi. The PVC can be bound when a 100Gi PV is added to the cluster.

Pods use claims as volumes. The cluster inspects the claim to find the bound volume and mounts that volume for a Pod. For those volumes that support multiple access modes, you must specify which mode applies when you use the claim as a volume in a Pod.

Once you have a claim and that claim is bound, the bound PV belongs to you for as long as you need it. You can schedule Pods and access claimed PVs by including persistentVolumeClaim in the Pod’s volumes block.

## Persisitent Volumes (PV)

Each PV contains a spec and status, which is the specification and status of the volume, for example:

PV object definition example

```text
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001 1
spec:
  capacity:
    storage: 5Gi 2
  accessModes:
    - ReadWriteOnce 3
  persistentVolumeReclaimPolicy: Retain 4
  ...
status:
  ...
```

- Name of the persistent volume. (1)
- The amount of storage available to the volume. (2)
- The access mode, defining the read-write and mount permissions. (3)
- The reclaim policy, indicating how the resource should be handled once it is released. (4)

### OpenShift Container Platform supports the following PersistentVolume plug-ins:

- AWS Elastic Block Store (EBS)
- Azure Disk
- Azure File
- Cinder
- Fibre Channel
- GCE Persistent Disk
- HostPath
- iSCSI
- Local volume
- NFS
- VMware vSphere

## Persistent Volume Claim (PVC)

Persistent volume claims
Each persistent volume claim (PVC) contains a spec and status, which is the specification and status of the claim, for example:

PVC object definition example

```text
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: myclaim 1
spec:
  accessModes:
    - ReadWriteOnce 2
  resources:
    requests:
      storage: 8Gi 3
  storageClassName: gold 4
status:
  ...
```

- Name of the PVC (1)
- The access mode, defining the read-write and mount permissions (2)
- The amount of storage available to the PVC (3)
- Name of the StorageClass required by the claim (4)

## Setup NFS (serverside)

In this workshop environment the services machine has been setup as the NFS server for your cluster.
On this NFS server, 6 shares have been exposed:

- /exports/registry
- /exports/vol1
- /exports/vol2
- /exports/vol3
- /exports/vol4
- /exports/vol5

### Selinux considerations

By default, SELinux does not allow writing from a Pod to a remote NFS server. The NFS volume mounts correctly, but is read-only.

To enable writing to a remote NFS server, follow the below procedure.

**Prerequisites**

The container-selinux package must be installed. This package provides the virt_use_nfs SELinux boolean.
Procedure

Enable the virt_use_nfs boolean using the following command. The -P option makes this boolean persistent across reboots.
For use with Openshift, we need to take care of Selinux by running a command on the NFS server:

```
$ # setsebool -P virt_use_nfs 1
```

## Using NFS storage

Using NFS storage is all handled via the PV and PVC objects, so no nfs client installation is needed. 
This said, the workernodes and masters (when using NFS for the registry) need to have the packages 
available on the OS to make the mount.

The developer requests storage by creating a PVC object. Here he describes the storage needs (how much, read-write-once, 
read-write-many, ready-only) etc.
The cluster admin makes available storage by creating PV objects to connect the actual storage to the cluster. 
When a storage requests comes to the cluster, the cluster matches the storage request to a piece of storage which matches 
or is better then the storage requested and then binds the PVC to the PV.

## EXERCISE - Use NFS for your cluster registry

As a cluster administrator, following installation you must configure your registry to use storage.

**Prerequisites**

- Cluster administrator permissions.
- provisioned persistent volume (PV) with ReadWriteMany access mode, such as NFS. Must have "100Gi" capacity.

For the registry, we do not create a separate PVC object since this is already defined in the DeploymentConfig of the registry.
In our workshop setup the services vm is the NFS server and the NFS export for registry is already configured.

**Your mission**

- create the Persistent Volume object (as cluster admin)
- reconfigure spec.storage.pvc

### Procedure

### create PV

Use the documentation to create a PV with at least 100Gi capacity. 

```text
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteOnce
  nfs:
    path: /exports/registry
    server: services.lab.example.com
  persistentVolumeReclaimPolicy: Retain
```

### Change spec.storage.pvc

To configure your registry to use storage, change the spec.storage.pvc in the configs.imageregistry/cluster resource.
Verify you do not have a registry Pod:

```text
$ oc get pod -n openshift-image-registry
```

> NOTE
> If the storage type is emptyDIR, the replica number cannot be greater than 1. If the storage type is NFS, and you want to scale up the registry Pod by setting replica>1 you must enable the no_wdelay mount option. For example:

### Check the registry configuration:

```text
$ oc edit configs.imageregistry.operator.openshift.io

storage:
  pvc:
    claim:
```

Leave the claim field blank to allow the automatic creation of an image-registry-storage PVC.

### Check the clusteroperator status:

```text
$ oc get clusteroperator image-registry
```

> Setting up a NFS server is beyond the scope of this workshop. 
> For more information, check out: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/ch-nfs

> For more o setting up storage on on Openshift Container Platform Cluster, check out:
> https://access.redhat.com/documentation/en-us/openshift_container_platform/4.2/html/storage/configuring-persistent-storage#persistent-storage-using-nfs
