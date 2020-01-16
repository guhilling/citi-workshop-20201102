## Container Image Registry

The registry uses a similar CRD (Custom Resource Definition) mechanism to
configure how the operator deploys the actual registry pods. That CRD is
configs.imageregistry.operator.openshift.io. You will need to edit the cluster
CR object in order to add the nodeSelector.

- First, take a look at it:

----

```
oc get configs.imageregistry.operator.openshift.io/cluster -o yaml
```

```
apiVersion: imageregistry.operator.openshift.io/v1
kind: Config
metadata:
  creationTimestamp: "2019-05-13T20:39:22Z"
  finalizers:
  imageregistry.operator.openshift.io/finalizer
  generation: 3
  name: cluster
  resourceVersion: "200927"
  selfLink: /apis/imageregistry.operator.openshift.io/v1/configs/cluster
  uid: 3077588d-75bf-11e9-8ad1-0af01fb55bd2
spec:
  defaultRoute: false
  httpSecret: 66b879954287368617ed5165caff19ebd07d2dabe4edb84509875623b9ff07914de72f832d4e80bb993d18220e935a65ce3b30e29eaf170f645b2d2e4a65a2c0
  logging: 2
  managementState: Managed
  proxy:
    http: ""
    https: ""
    noProxy: ""
  readOnly: false
  replicas: 1
  requests:
  read:
    maxInQueue: 0
    maxRunning: 0
    maxWaitInQueue: 0s
  write:
    maxInQueue: 0
    maxRunning: 0
    maxWaitInQueue: 0s
(...)
```

Next, let's modify the custom resource by live-patching the configuration.
For this we can use oc edit, and you'll need to modify the .spec section:

----

```
oc edit configs.imageregistry.operator.openshift.io/cluster
```

The .spec section will need to look like the following:

```
  nodeSelector:
    node-role.kubernetes.io/infra: ""
```

----

- Once you're done, save and exit the editor, and it should confirm the change:

```
config.imageregistry.operator.openshift.io/cluster edited
```

> NOTE: The nodeSelector stanza may be added anywhere inside the .spec block.

When you save and exit you should see the registry pod being moved to the infra
node. The registry is in the openshift-image-registry project. If you execute
the following quickly enough, you may see the old registry pods terminating and
the new ones starting.:

```
oc get pod -n openshift-image-registry
NAME                                               READY   STATUS        RESTARTS   AGE
cluster-image-registry-operator-5644775d7c-w78kh   1/1     Running       0          34h
image-registry-5878c9d896-nmkc6                    1/1     Terminating   0          22h
node-ca-2ljck                                      1/1     Running       0          22h
node-ca-9npbz                                      1/1     Running       0          34h
node-ca-mk9lj                                      1/1     Running       0          34h
node-ca-pspwx                                      1/1     Running       0          34h
node-ca-qlxqx                                      1/1     Running       0          9h
node-ca-qvslw                                      1/1     Running       0          34h
node-ca-wxb55                                      1/1     Running       0          34h
node-ca-xn9vg                                      1/1     Running       0          22h
```

> NOTE: At this time the image registry is not using a separate project for its operator. Both the operator and the operand are housed in the openshift-image-registry project.

Since the registry is being backed by an S3 bucket, it doesn't matter what node the new registry pod instance lands on. It's talking to an object store via an API, so any existing images stored there will remain accessible.

Also note that the default replica count is 1. In a real-world environment you might wish to scale that up for better availability, network throughput, or other reasons.

If you look at the node on which the registry landed (noting that you'll likely have to refresh your list of pods by using the previous commands to get its new name):

```
oc get pod image-registry-5878c9d896-nmkc6 -n openshift-image-registry -o wide
NAME                              READY   STATUS    RESTARTS   AGE   IP           NODE                                         NOMINATED NODE   READINESS GATES
image-registry-5878c9d896-nmkc6   1/1     Running   0          22h   10.131.4.5   ip-10-0-139-255.us-east-2.compute.internal   <none>           <none>
```

> NOTE: the pod name will be different in your environment

it is now running on an infra worker:

```
oc get node ip-10-0-139-255.us-east-2.compute.internal
NAME                                         STATUS   ROLES          AGE   VERSION
ip-10-0-139-255.us-east-2.compute.internal   Ready    infra,worker   22h   v1.13.4+c3617b99f
```

> Notice that the CRD for the image registry's configuration is not
> namespaced -- it is cluster scoped. There is only one internal/integrated
> registry per OpenShift cluster that serves all projects.

## 
