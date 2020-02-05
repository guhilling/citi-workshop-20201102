# Postinstallation Infrastructure Nodes

In this Postinstallation Task, we will turn Worker Nodes into Infrastructure Nodes.

The reason is that after the initial deployment,  an OpenShift 4 Cluster just include master and worker nodes, while OpenShift 3 used to ship with master, infra and compute nodes.

The worker nodes in OpenShift 4 are meant to replace both infra and worker nodes, which could make sense running smaller setups, though we would argue that is not practical to scale out in larger environments with hundrets of worker nodes. Having a small set of nodes, designated to host OpenShift ingress controllers is a good thing, as we only need to configure those IPs as backends for our applications loadbalancers. If we have not seperated infra from  worker nodes, every time we add new members to our cluster, we would also need reconfiguring our loadbalancer. At the end we could have hundrets of possible worker nodes on our external Loadbalancer acts as a possible endpoint for Openshift Routers.

To prevent this we would create a group of Infra machines, starting with creating a MachineConfigPool, using the following configuration:

```
[root@services ~]# mkdir -p /root/openshift/machineconfiguration/
```

```
[root@services ~]# vim /root/openshift/machineconfiguration/infra-machineconfigpool.yaml
```

```
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

```
[root@services ~]# oc apply -f infra-machineconfigpool.yaml
```

Having applied that configuration, we would then dump MachineConfig (mc) objects applying to worker nodes:

```
[root@services ~]# oc get mc|grep worker|grep -v rendered|awk '{print $1}'
```

```
00-worker
01-worker-container-runtime
01-worker-kubelet
99-worker-e4a0d91a-3206-11ea-aab6-525400e1788a-registries
99-worker-ssh
```

Now we need to dump worker config into a yaml file for infra nodes:

```
[root@services ~]# oc get mc 01-worker-container-runtime > 01-infra-container-runtime.yaml
```

```
[root@services ~]# oc get mc 01-worker-kublet > 01-infra-kublet.yaml
```

```
oc get mc 99-worker-e4a0d91a-3206-11ea-aab6-525400e1788a-registries > 99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries.yaml
```

```
[root@services ~]# oc get mc 99-worker-ssh > 99-infra-ssh.yaml
```

We now edit the five machineconfig-infra yaml files content, removing the following informations:

*“generated-by” annotations,
creationTimestamps,
generation,
ownerReferences,
resourceVersions,
selfLink,
uid metadata.*

Next we need to replace any remaning mention of “worker” by “infra”. 

After done our modification we then apply the resulting objects

```
[root@services ~]# oc apply -f 00-infra.yaml
```

```
[root@services ~]# oc apply -f 01-infra-container-runtime.yaml
```

```
[root@services ~]# oc apply -f 01-infra-kublet.yaml
```

```
[root@services ~]# oc apply -f 99-infra-e4a0d91a-3206-11ea-aab6-525400e1788a-registries.yaml
```

```
[root@services ~]# oc apply -f 99-infra-ssh.yaml
```

Check that the mc are present now:

```
[root@service ~}# oc get mc
```

Once `oc get mc` includes that rendered configuration, we would make sure the MachineConfig Operator is done with our MachineConfigPool and start re-labeling nodes accordingly:

```
[root@services ~]# oc label node worker03 node-role.kubernetes.io/infra=
[root@services ~]# oc label node worker04 node-role.kubernetes.io/infra=

```

and:

```
[root@services ~]# oc label node worker03 node-role.kubernetes.io/worker-
[root@services ~]# oc label node worker04 node-role.kubernetes.io/worker-
```

From there, our node would be set unschedulable, drained, and rebooted. Our customized MachineConfig should have changed the role label applied when our node boots, which we may confirm once it is done restarting

```
[root@services ~]# oc get nodes
```

```
NAME STATUS ROLES AGE VERSION
master01 Ready master,worker 29h v1.14.6+cebabbf4a
master02 Ready master,worker 29h v1.14.6+cebabbf4a
master03 Ready master,worker 29h v1.14.6+cebabbf4a
infra01 Ready infra 29h v1.14.6+6ac6aa4b0
infra02 Ready infra 29h v1.14.6+6ac6aa4b0
worker03 Ready worker 25h v1.14.6+cebabbf4a
```

When our node is back, we would proceed with the next infra node.

We would eventually reconfigure our Ingress Controller deploying OpenShift Routers back to our infra nodes:

```
[root@service ~]# oc edit -n openshift-ingress-operator ingresscontroller default
```

```
spec:
 nodePlacement:
   nodeSelector:
     matchLabels:
       node-role.kubernetes.io/infra: ""
 replicas: 2
```

We would then keep track of routers pods as they’re being re-deployed:

```
[root@service ~]# oc get pods -n openshift-ingress -o wide
```

```
NAME READY STATUS RESTARTS AGE IP NODE NOMINATED NODE READINESS GATES
router-default-86459f48b9-7t9nb 1/1 Running 0 1m 192.168.100.31 infra01 <none>  <none>
router-default-86459f48b9-85q6l 1/1 Running 0 1m 192.168.100.32 infra02 <none>  <none>
```

Now we are done, we have seperated worker from infra nodes and have dedicated infra nodes in our Openshift Cluster.
