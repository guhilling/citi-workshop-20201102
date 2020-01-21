# Postinstallation Infrastructure Nodes

In this Postinstallation Task, we will turn Worker Nodes into Infrastructure Nodes.

The reason is that after the initial deployment, of an OpenShift 4 Cluster just include master and worker nodes, while OpenShift 3 used to ship with master, infra and compute nodes.

The worker nodes in OpenShift 4 are meant to replace both infra and computes, which could make sense running smaller setups, though we would argue that is not practical to scale out in larger environments. Having a small set of nodes, designated to host OpenShift ingress controllers is a good thing, as we only need to configure those IPs as backends for our applications loadbalancers. Say we only rely on worker nodes, every time we add new members to our cluster, we would also need reconfiguring our loadbalancer.

Hence, we would create a group of Infra machines, starting with creating a MachineConfigPool, using the following cofiguration:

```
infra-machineconfigpool.yaml
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

we need to apply:

```
oc apply -f infra-machineconfigpool.yaml
```

Having applied that configuration, we would then dump MachineConfig objects applying to worker nodes:

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

bla

```
[root@services ~]# oc get mc 00-worker > 00-infra.yaml
```

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

We would then edit the five machineconfig-infra yaml files content, removing
“generated-by” annotations,
creationTimestamps,
generation,
ownerReferences,
resourceVersions,
selfLink,
uid metadata.
Replace any remaning mention of “worker” by “infra”. Then apply the resulting objects

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

Check that the mc are present now

```
[root@service ~}# oc get mc
```

Once oc get mc includes that rendered configuration, we would make sure the MachineConfig Operator is done with our MachineConfigPool and start re-labeling nodes accordingly:

```
[root@services ~]# oc label node infra1.nodes.example.com node-role.kubernetes.io/infra=
node/infra1.nodes.example.com labeled
```

bla

```
[root@services ~]# oc label node infra1.nodes.example.com node-role.kubernetes.io/worker-
node/infra1.nodes.example.com labeled
```

From there, our node would be set unschedulable, drained, and rebooted. Our customized MachineConfig should have changed the role label applied when our node boots, which we may confirm once it is done restarting

```
[root@services ~]# oc get nodes
```

```

```












