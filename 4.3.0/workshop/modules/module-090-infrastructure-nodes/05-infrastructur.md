# Postinstallation Infrastructure Nodes

In this Postinstallation Task, we will turn Worker Nodes into Infrastructure Nodes.

The reason is that after the initial deployment,  an OpenShift 4 Cluster just include master and worker nodes, while OpenShift 3 used to ship with master, infra and compute nodes.

The worker nodes in OpenShift 4 are meant to replace both infra and worker nodes, which could make sense running smaller setups, though we would argue that is not practical to scale out in larger environments with hundrets of worker nodes. Having a small set of nodes, designated to host OpenShift ingress controllers is a good thing, as we only need to configure those IPs as backends for our applications loadbalancers. If we have not seperated infra from  worker nodes, every time we add new members to our cluster, we would also need reconfiguring our loadbalancer. At the end we could have hundrets of possible worker nodes on our external Loadbalancer acts as a possible endpoint for Openshift Routers.

To prevent this we would create a group of Infra machines, starting with creating a MachineConfigPool, using the following configuration
```sh
[root@services ~]# vim /root/openshift/machineconfiguration/infra-machineconfigpool.yaml
```

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: infra
spec:
  machineConfigSelector:
    matchLabels:
      machineconfiguration.openshift.io/role: infra
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/infra: ""
  paused: false
```

After crerating the configuration file we need to apply this to our cluster:

```sh
[root@services ~]# oc create -f infra-machineconfigpool.yaml
```
```
oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT
infra                                                                                       0              0                   0                     0
master   rendered-master-9b499c1cfc683a5ba9a54c47ce7570d3   True      False      False      3              3                   3                     0
worker   rendered-worker-da58576c03c205503967c5fdf465ab80   True      False      False      4              4                   4                     0
```
Because just an empty machineconfigpool infra is now existing there's no info at all about it.


Having applied that configuration, we would then dump MachineConfig (mc) objects applying to worker nodes

```sh
[root@services ~]# oc get mc|grep worker|grep -v rendered|awk '{print $1}'
```

```sh
00-worker
01-worker-container-runtime
01-worker-kubelet
99-worker-e4a0d91a-3206-11ea-aab6-525400e1788a-registries
99-worker-ssh
```

Now we need to dump worker config into a yaml file for infra nodes

```sh
[root@services ~]# oc get mc 00-worker -o yaml > 00-infra.yaml
```

```sh
[root@services ~]# oc get mc 01-worker-container-runtime -o yaml > 01-infra-container-runtime.yaml
```

```sh
[root@services ~]# oc get mc 01-worker-kubelet -o yaml > 01-infra-kubelet.yaml
```

```sh
[root@services ~]# oc get mc 99-worker-e4a0d91a-3206-11ea-aab6-525400e1788a-registries -o yaml > 99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries.yaml
```

```sh
[root@services ~]# oc get mc 99-worker-ssh -o yaml > 99-infra-ssh.yaml
```

We now edit the five machineconfig-infra yaml files content, removing the following informations:

annotations
machineconfiguration.openshift.io/generated-by-controller-version,
creationTimestamp,
generation,
ownerReferences,
:q!
resourceVersion,
selfLink,
uid metadata.*

And we need to replace any remaning mention of “worker” by “infra”. 
```sh
[root@services ~]# sed -i -e '/annotations/,+1d' -e '/creationTimestamp/d' -e'/generation/d' -e '/ownerReference/,+6d' -e '/resourceVersion/d' -e '/selfLink/d' -e '/uid/ {/data/!d}' -e 's/worker/infra/' 00-infra.yaml
```
```sh
[root@services ~]# sed -i -e '/annotations/,+1d' -e '/creationTimestamp/d' -e'/generation/d' -e '/ownerReference/,+6d' -e '/resourceVersion/d' -e '/selfLink/d' -e '/uid/ {/data/!d}' -e 's/worker/infra/' 01-infra-container-runtime.yaml
```
```sh
[root@services ~]# sed -i -e '/annotations/,+1d' -e '/creationTimestamp/d' -e'/generation/d' -e '/ownerReference/,+6d' -e '/resourceVersion/d' -e '/selfLink/d' -e '/uid/ {/data/!d}' -e 's/worker/infra/' 01-infra-kubelet.yaml
```
```sh
[root@services ~]# sed -i -e '/annotations/,+1d' -e '/creationTimestamp/d' -e'/generation/d' -e '/ownerReference/,+4d' -e '/resourceVersion/d' -e '/selfLink/d' -e '/uid/ {/data/!d}' -e 's/worker/infra/' 99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries.yaml
```
```sh
[root@services ~]# sed -i -e '/annotations/,+1d' -e '/creationTimestamp/d' -e'/generation/d' -e '/ownerReference/,+6d' -e '/resourceVersion/d' -e '/selfLink/d' -e '/uid/ {/data/!d}' -e 's/worker/infra/' 99-infra-ssh.yaml
```
After we're done with our modifications we then applying the resulting files

```sh
[root@services ~]# oc create -f 00-infra.yaml
machineconfig.machineconfiguration.openshift.io/00-infra created
```

```sh
[root@services ~]# oc create -f 01-infra-container-runtime.yaml
machineconfig.machineconfiguration.openshift.io/01-infra-container-runtime created
```

```sh
[root@services ~]# oc create -f 01-infra-kubelet.yaml
machineconfig.machineconfiguration.openshift.io/01-infra-kubelet created

```

```sh
[root@services ~]# oc create -f 99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries.yaml
machineconfig.machineconfiguration.openshift.io/99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries created
```

```sh
[root@services ~]# oc create -f 99-infra-ssh.yaml
machineconfig.machineconfiguration.openshift.io/99-infra-ssh created
```

Check that the mc are present now:

```sh
[root@service ~]# oc get mc
NAME                                                        GENERATEDBYCONTROLLER                      IGNITIONVERSION   CREATED
00-infra                                                                                               2.2.0             8m42s
00-master                                                   25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
00-worker                                                   25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
01-infra-container-runtime                                                                             2.2.0             7m53s
01-infra-kubelet                                                                                       2.2.0             5m45s
01-master-container-runtime                                 25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
01-master-kubelet                                           25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
01-worker-container-runtime                                 25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
01-worker-kubelet                                           25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
99-infra-bd385908-d77b-416f-9f22-eb6ab3a141d5-registries                                               2.2.0             4m51s
99-infra-ssh                                                                                           2.2.0             3m51s
99-master-bd73a936-a864-408b-b10f-a198dc4ff6a3-registries   25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
99-master-ssh                                                                                          2.2.0             30h
99-worker-bd385908-d77b-416f-9f22-eb6ab3a141d5-registries   25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
99-worker-ssh                                                                                          2.2.0             30h
rendered-infra-52ec490315c0f8fb1d384a363731c05f             25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             2m28s
rendered-master-9b499c1cfc683a5ba9a54c47ce7570d3            25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
rendered-worker-da58576c03c205503967c5fdf465ab80            25bb6aeb58135c38a667e849edf5244871be4992   2.2.0             30h
```

Once `oc get mc` includes that rendered infra configuration (rendered-infra-52ec490315c0f8fb1d384a363731c05f), we would make sure the MachineConfig Operator is done with our MachineConfigPool and start re-labeling nodes accordingly:

```sh
[root@services ~]# oc label node worker03 node-role.kubernetes.io/infra=
node/worker04 labeled
```

and:

```sh
[root@services ~]# oc label node worker03 node-role.kubernetes.io/worker-
node/worker04 labeled
```

From there, our node would be set unschedulable, drained, and rebooted. Our customized MachineConfig should have changed the role label applied when our node boots, which we may confirm once it is done restarting

```sh
[root@services ~]# oc get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    master,worker   30h   v1.16.2
master02   Ready    master,worker   30h   v1.16.2
master03   Ready    master,worker   30h   v1.16.2
worker01   Ready    worker          30h   v1.16.2
worker02   Ready    worker          30h   v1.16.2
worker03   Ready    infra           13h   v1.16.2
worker04   Ready    infra           13h   v1.16.2
```

When our node is back, we would proceed with the next infra node.
Check after you modified the last node the machineconfigpool once again
```
[root@services ~]# oc get mcp
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED   MACHINECOUNT   READYMACHINECOUNT   UPDATEDMACHINECOUNT   DEGRADEDMACHINECOUNT
infra    rendered-infra-52ec490315c0f8fb1d384a363731c05f    True      False      False      2              2                   2                     0
master   rendered-master-9b499c1cfc683a5ba9a54c47ce7570d3   True      False      False      3              3                   3                     0
worker   rendered-worker-da58576c03c205503967c5fdf465ab80   True      False      False      4              4                   4                     0
```

We would eventually reconfigure our Ingress Controller deploying OpenShift Routers back to our infra nodes:

```sh
[root@service ~]# oc edit -n openshift-ingress-operator ingresscontroller default
```

```yaml
...
spec:
 nodePlacement:
   nodeSelector:
     matchLabels:
       node-role.kubernetes.io/infra: ""
 replicas: 2
...
```
or run an oc patch command
```sh
[root@services ~]# oc patch ingresscontrollers.operator.openshift.io default -n openshift-ingress-operator -p '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}' --type=merge
ingresscontroller.operator.openshift.io/default patched
```

We would then keep track of routers pods as they’re being re-deployed to the infra nodes

```sh
[root@service ~]# oc get pods -n openshift-ingress -o wide
NAME                              READY   STATUS    RESTARTS   AGE   IP               NODE       NOMINATED NODE   READINESS GATES
router-default-7d66988b48-rkwfm   1/1     Running   0          30h   192.168.100.33   worker03   <none>           <none>
router-default-7d66988b48-xsl2k   1/1     Running   0          30h   192.168.100.34   worker04   <none>           <none>
```

By default there are two router, if you have to have more e.g. three infra nodes modify once again the Ingress Controller

> Do not forget to reconfigure the loadbalancer so it will point to the infras!

```sh
[root@services ~]# oc patch ingresscontrollers.operator.openshift.io default -n openshift-ingress-operator --patch '{"spec":{"replicas": 3}}' --type=merge
ingresscontroller.operator.openshift.io/default patched
```
Check the amount of routers
```sh
[root@services ~]# oc get pods -n openshift-ingress -o wide
NAME                              READY   STATUS    RESTARTS   AGE   IP               NODE       NOMINATED NODE   READINESS GATES
router-default-7d66988b48-9fg6b   1/1     Running   0          20s   192.168.100.33   worker03   <none>           <none>
router-default-7d66988b48-k485m   1/1     Running   0          11m   192.168.100.34   worker04   <none>           <none>
router-default-7d66988b48-vvss7   1/1     Running   0          11m   192.168.100.35   worker05   <none>           <none>
```
Place the image registry pod on the infra node
```sh
[root@services ~]# oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge -p '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra": ""}}}'
```
Check the image registry pod placement
```sh
[root@services ~]# oc get pods -n openshift-image-registry -o wide
NAME                                              READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
cluster-image-registry-operator-f9697f69d-fzq5j   2/2     Running   0          30h   10.129.0.14   master03   <none>           <none>
image-registry-6f5d69f654-jxh6h                   1/1     Running   0          58s   10.128.2.18   worker39   <none>           <none>
node-ca-52ts7                                     1/1     Running   0          14h   10.131.0.41   master01   <none>           <none>
node-ca-8w2pw                                     1/1     Running   1          14h   10.130.2.3    worker04   <none>           <none>
node-ca-l8qhg                                     1/1     Running   0          14h   10.128.2.17   worker02   <none>           <none>
node-ca-lcbk5                                     1/1     Running   0          14h   10.128.0.16   worker01   <none>           <none>
node-ca-nwt2x                                     1/1     Running   1          14h   10.129.2.3    worker03   <none>           <none>
node-ca-qcbsg                                     1/1     Running   0          14h   10.129.0.30   master03   <none>           <none>
node-ca-vm94k                                     1/1     Running   0          14h   10.130.0.42   master02   <none>           <none>
```

Now we are done, we have seperated worker from infra nodes and have dedicated infra nodes in our Openshift Cluster.