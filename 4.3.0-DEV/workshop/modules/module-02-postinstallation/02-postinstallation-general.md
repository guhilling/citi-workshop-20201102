After we have done the installation we can check the cluster is up and running type in the following command:

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

## Troubleshooting: Pending  Certificates

When you add machines to a cluster, two pending certificates signing request (CSRs) are generated for each machine that you added. You must verify that these CSRs are approved or, if necessary, approve them yourself.

```
[root@services ~]# oc get nodes
```

```
NAME STATUS ROLES AGE VERSION
master Ready master 63m v1.14.6+c4799753c
master2 Ready master 63m v1.14.6+c4799753c
master3 Ready master 64m v1.14.6+c4799753c
worker1 NotReady worker 76s v1.14.6+c4799753c
worker2 NotReady worker 70s v1.14.6+c4799753c
...
```

The output lists all of the machines that we created.

Now we need to review the pending certificate signing requests (CSRs) and ensure that the you see a client and server request with `Pending` or `Approved` status for each machine that you added to the cluster:

```
[root@services ~]# oc get csr
```

```
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

## Completing installation on User Provisioned Infrastructure:

After we complete the operator configuration, you can finish installing the cluster on infrastructure that you provide.

We need to confirm that all components are up and running.

```
 [root@services ~]# watch -n5 oc get clusteroperators
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
