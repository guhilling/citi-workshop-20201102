## Installing OpenShift Logging

In this section we describe the installation of OpenShift Cluster Aggregated Logging, the EFK (ElasticSearch - Fluentd - Kibana) components.

Reference: [Product Documentation - Deploying cluster logging](https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-deploying.html)

This section focusses on installation of the Cluster Logging components. For the initial installation, we add ephemeral storage only. Adding persistent storage is described in an extra module.

The deployment of the logging components requires to install two additional Operators.

- The operator for ElasticSearch is installed in namespace 'openshift-operators-redhat'
- The main Cluster Logging operator is installed in namespace 'openshift-logging'

The namespace 'openshift-logging' will be later on used by the operators to rollout the component pods for ElasticSearch, FluentD and Kibana as well.

### Create the Namespaces

Create a Namespace for the Elasticsearch Operator (for example, namespace-es.yaml) and create using `oc create -f namespace-es.yaml`:

```
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-operators-redhat 
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-logging: "true"
    openshift.io/cluster-monitoring: "true"
```

Create a Namespace for the Cluster Logging Operator (for example, namespace-logging.yaml) and create using `oc create -f namespace-logging.yaml`:

```
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-logging
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-logging: "true"
    openshift.io/cluster-monitoring: "true"
```

### Deploy the ES Operator

Create two Operator Group object YAML files (for example, og-es.yaml and og-logging.yaml) for the Elasticsearch operator and create using `oc create -f og-es.yaml oc create -f og-logging.yaml`:

og-logging.yaml
```
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-operators-redhat
  namespace: openshift-operators-redhat 
spec: {}
```
and:

og-es.yaml
```
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-logging
  namespace: openshift-logging 
spec:
  targetNamespaces:
  - "openshift-logging"
```

Use the following command to get the channel value required for the next step.

```
[root@services ~]# oc get packagemanifest elasticsearch-operator -n openshift-marketplace -o jsonpath='{.status.channels[].name}'
```

Create a Subscription object YAML file (for example, operator-sub-es.yaml) to subscribe a Namespace to an Operator and create using `oc create -f operator-sub-es.yaml`. Put the channel value to the file.

```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  generateName: "elasticsearch-"
  namespace: "openshift-operators-redhat" 
spec:
  channel: "4.2" 
  installPlanApproval: "Automatic"
  source: "redhat-operators"
  sourceNamespace: "openshift-marketplace"
  name: "elasticsearch-operator"
```

Change to the openshift-operators-redhat project:

```
[root@services ~]# oc project openshift-operators-redhat
```

Create a Role-based Access Control (RBAC) object file (for example, rbac-es.yaml) to grant Prometheus permission to access the openshift-operators-redhat namespace. And create using `oc create -f rbac-es.yaml`.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-k8s
  namespace: openshift-operators-redhat
rules:
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  - pods
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-k8s
  namespace: openshift-operators-redhat
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-k8s
subjects:
- kind: ServiceAccount
  name: prometheus-k8s
namespace: openshift-operators-redhat
```

### Install Cluster Logging Operator

Change to the openshift-logging project:

```
[root@services ~]# oc project openshift-logging
```

Use the following command to get the channel value required for the next step.

```
[root@services ~]# oc get packagemanifest cluster-logging -n openshift-marketplace -o jsonpath='{.status.channels[].name}'
```

Create a Subscription object YAML file (for example, operator-sub-logging.yaml) to subscribe a Namespace to an Operator and create using `oc create -f operator-sub-logging.yaml`. Put the channel value to the file.

```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: "cluster-logging"
  namespace: "openshift-logging" 
spec:
  channel: "4.2" 
  installPlanApproval: "Automatic"
  source: "redhat-operators"
  sourceNamespace: "openshift-marketplace"
  name: "cluster-logging"
```

### Check Operator Installation

Once the steps for the Operator installation are executed, the operators incl. their pods as well as the Custom Resource Definitions (CRDs) should be visible:

Check the existence of the operators:

```
[root@services ~]# oc get clusterserviceversion
```

```
NAME DISPLAY VERSION REPLACES PHASE
clusterlogging.4.2.13-201912230557 Cluster Logging 4.2.13-201912230557 Succeeded
elasticsearch-operator.4.2.13-201912230557 Elasticsearch Operator 4.2.13-201912230557 Succeeded
```

Check existence of pods for both operators:

```
[root@services ~]# oc get pods -n openshift-operators-redhat
```

```
NAME READY STATUS RESTARTS AGE
elasticsearch-operator-74bb66456c-mgtt6 1/1 Running 0 30m
```

```
[root@services ~]# oc get pods -n openshift-logging
```

```
NAME READY STATUS RESTARTS AGE
cluster-logging-operator-5cb9bf8c7f-pfg6t 1/1 Running 0 9m41s
```

Check existance of the Custom Ressource Definition (CRD) objects for logging:

```
[root@services ~]# oc get crd | grep loggin
```

```
clusterloggings.logging.openshift.io 2020-01-10T09:16:59Z
elasticsearches.logging.openshift.io 2020-01-10T09:02:30Z
```

### Deloy Cluster Logging Components (using the operators)

We now rollout the cluster logging components using the installed operators.

As noted above, we install ElasticSearch using ephemeral storage only in this chapter. Adding persistent storage is described in Chapter 3. Note you can install ElasticSearch with persistent storage when cominbing the information of Chapter 3 with this basic installation approach.

Create a CRD for logging (for example, cust-resource-def-logging.yaml) to subscribe a Namespace to an Operator and create using `oc create -f cust-resource-def-logging.yaml`.
We initially leave the storage definition empty to rollout ElasticSearch with ephemeral storage and add storage later on.

> Note: We rollout only 2 ElasticSearch replicas on 2 nodes and configure ElasticSearch for a minimal memory requests (2GB rather than the default 16 GB) due to the available resources in our workshop environment.

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
      storage: {}
      redundancyPolicy: "SingleRedundancy"
      resources:
        limits:
          memory: "2Gi"
        requests:
          cpu: "1"
          memory: "2Gi"
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

Wait a few moments and look for the Operator to rollout route, services, deployments, and pods:

```
[root@services ~]# oc get all
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
pod/cluster-logging-operator-5cb9bf8c7f-pfg6t       1/1     Running   1          2d4h
pod/curator-1578799800-5lpjt                        1/1     Running   0          10h
pod/elasticsearch-cdm-07r3062k-1-bb476b875-gmfwn    1/2     Running   0          47h
pod/elasticsearch-cdm-07r3062k-2-5dcb98d664-9dpwh   1/2     Running   0          47h
pod/fluentd-2cvjm                                   1/1     Running   2          47h
pod/fluentd-hl48p                                   1/1     Running   2          47h
pod/fluentd-qhkrb                                   1/1     Running   2          47h
pod/fluentd-r42mq                                   1/1     Running   2          47h
pod/fluentd-z6vhs                                   1/1     Running   2          47h
pod/kibana-655fb977b7-ktq9s                         2/2     Running   0          47h

NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/elasticsearch           ClusterIP   172.30.165.102   <none>        9200/TCP    47h
service/elasticsearch-cluster   ClusterIP   172.30.255.210   <none>        9300/TCP    47h
service/elasticsearch-metrics   ClusterIP   172.30.25.76     <none>        60000/TCP   47h
service/fluentd                 ClusterIP   172.30.211.126   <none>        24231/TCP   47h
service/kibana                  ClusterIP   172.30.228.176   <none>        443/TCP     47h

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/fluentd   5         5         5       5            5           kubernetes.io/os=linux   47h

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-logging-operator       1/1     1            1           2d4h
deployment.apps/elasticsearch-cdm-07r3062k-1   0/1     1            0           47h
deployment.apps/elasticsearch-cdm-07r3062k-2   0/1     1            0           47h
deployment.apps/kibana                         1/1     1            1           47h

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/cluster-logging-operator-5cb9bf8c7f       1         1         1       2d4h
replicaset.apps/elasticsearch-cdm-07r3062k-1-bb476b875    1         1         0       47h
replicaset.apps/elasticsearch-cdm-07r3062k-2-5dcb98d664   1         1         0       47h
replicaset.apps/kibana-655fb977b7                         1         1         1       47h

NAME                    SCHEDULE     SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/curator   30 3 * * *   False     0        10h             47h

NAME                              HOST/PORT                                            PATH   SERVICES   PORT    TERMINATION          WILDCARD
route.route.openshift.io/kibana   kibana-openshift-logging.apps.ocp4.hX.rhaw.io          kibana     <all>   reencrypt/Redirect   None
```

```
[root@services ~]# oc get pods
```

```
NAME READY STATUS RESTARTS AGE
cluster-logging-operator-5cb9bf8c7f-pfg6t 1/1 Running 1 2d4h
curator-1578799800-5lpjt 1/1 Running 0 47h
elasticsearch-cdm-07r3062k-1-bb476b875-gmfwn 1/2 Running 0 47h
elasticsearch-cdm-07r3062k-2-5dcb98d664-9dpwh 1/2 Running 0 47h
fluentd-2cvjm 1/1 Running 2 47h
fluentd-hl48p 1/1 Running 2 47h
fluentd-qhkrb 1/1 Running 2 47h
fluentd-r42mq 1/1 Running 2 47h
fluentd-z6vhs 1/1 Running 2 47h
kibana-655fb977b7-ktq9s 2/2 Running 0 47h
```

After these steps we should have a full working EFK Logging Stack on our Openshift Cluster
