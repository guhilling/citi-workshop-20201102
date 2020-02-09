## Exploring the Cluster

In this module, we will review the OpenShift Web Console.

Let's take some time to explore our OCP4 cluster. We now have two options, we can use our local terminal on our laptop, or we can use the browser-based terminal that we provisioned in the previous section. Due to connectivity challenges, we maybe forced to use the browser-based one, and for convenience our recommendation would be to use it. If we really want to configure our local client we can do so by using the following instructions to download the command line tooling. We should only do this if we don't want to use the browser-based terminal; we need to make sure we run this on our local laptop and NOT within the web-browser.

Currently using the OC client CLI from https://access.redhat.om. We can
check if there is an updated one before running the download instruction.We can
update the URL accordingly if you like.

#### For Linux:

```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.14/openshift-client-linux-4.2.14.tar.gz
...
oc version
```

#### For Mac  OSX:

```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.14/openshift-client-mac-4.2.14.tar.gz
...

oc version
```

#### For Windows:

- Download CLI from https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.0/openshift-client-windows-4.2.14.zip
- Extract the downloaded zip file.
- Download download git bash for Windows from http://git-scm.com is recommended
- Set up PATH on your Windows laptop

## Login via CLI

Let's now configure our command line tooling to point to our new cluster.
Below you'll need to enter the API URI, which will be shown as the "Openshift API for command line 'oc' client".
OCP4 CLI login require the [https://api.ocp4.hX.rhaw.io:6443](https://api.ocp4.hX.rhaw.io:6443) not the master URL.

```
$ oc login --server https://api.ocp4.hX.rhaw.io:6443
```

```
...
The server uses a certificate signed by an unknown authority.
You can bypass the certificate check, but any data you send to the server could be intercepted by others.
Use insecure connections? (y/n): y

Authentication required for https://api.ocp4.hX.rhaw.io:6443 (openshift)
Username: <your username>
Password: <your password>
Login successful.
...
```

We can now check that your config has been written successfully:

```
$ cat ~/.kube/config
```

```
apiVersion: v1
clusters:
cluster:
 insecure-skip-tls-verify: true
 server: https://api.ocp4.hX.rhaw.io:6443
```

Now that your client CLI is installed, you will have access to the web console and can use the CLI. Below are some command-line exercises to explore the cluster.

### Cluster Nodes

The default installation behavior creates 6 nodes: 3 masters and 3 "worker" application/compute nodes. You can view them with:

```
$ oc get nodes -o wide
```

```
NAME       STATUS   ROLES           AGE   VERSION             INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                                                   KERNEL-VERSION                CONTAINER-RUNTIME
master01   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   192.168.100.21   <none>        Red Hat Enterprise Linux CoreOS 42.81.20191119.1 (Ootpa)   4.18.0-147.0.3.el8_1.x86_64   cri-o://1.14.11-0.24.dev.rhaos4.2.gitc41de67.el8
master02   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   192.168.100.22   <none>        Red Hat Enterprise Linux CoreOS 42.81.20191119.1 (Ootpa)   4.18.0-147.0.3.el8_1.x86_64   cri-o://1.14.11-0.24.dev.rhaos4.2.gitc41de67.el8
master03   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   192.168.100.23   <none>        Red Hat Enterprise Linux CoreOS 42.81.20191119.1 (Ootpa)   4.18.0-147.0.3.el8_1.x86_64   cri-o://1.14.11-0.24.dev.rhaos4.2.gitc41de67.el8
worker01   Ready    worker          15h   v1.14.6+6ac6aa4b0   192.168.100.31   <none>        Red Hat Enterprise Linux CoreOS 42.81.20191119.1 (Ootpa)   4.18.0-147.0.3.el8_1.x86_64   cri-o://1.14.11-0.24.dev.rhaos4.2.gitc41de67.el8
worker02   Ready    worker          15h   v1.14.6+6ac6aa4b0   192.168.100.32   <none>        Red Hat Enterprise Linux CoreOS 42.81.20191119.1 (Ootpa)   4.18.0-147.0.3.el8_1.x86_64   cri-o://1.14.11-0.24.dev.rhaos4.2.gitc41de67.el8
```

If you want to see the various applied labels, you can also do:

```
$ oc get nodes --show-labels
```

```
NAME       STATUS   ROLES           AGE   VERSION             LABELS
master01   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=master01,kubernetes.io/os=linux,node-role.kubernetes.io/master=,node-role.kubernetes.io/worker=,node.openshift.io/os_id=rhcos
master02   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=master02,kubernetes.io/os=linux,node-role.kubernetes.io/master=,node-role.kubernetes.io/worker=,node.openshift.io/os_id=rhcos
master03   Ready    master,worker   15h   v1.14.6+6ac6aa4b0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=master03,kubernetes.io/os=linux,node-role.kubernetes.io/master=,node-role.kubernetes.io/worker=,node.openshift.io/os_id=rhcos
worker01   Ready    worker          15h   v1.14.6+6ac6aa4b0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=worker01,kubernetes.io/os=linux,node-role.kubernetes.io/worker=,node.openshift.io/os_id=rhcos
worker02   Ready    worker          15h   v1.14.6+6ac6aa4b0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=worker02,kubernetes.io/os=linux,node-role.kubernetes.io/worker=,node.openshift.io/os_id=rhcos
```

For reference, labels are used as a mechanism to tag certain information onto a node, or a set of nodes, that can help you identify your systems, e.g. by operating system, system architecture, specification, location of the system (e.g. region), it's hostname, etc. They can also help with application scheduling, e.g. make sure that my application (or pod) resides on a specific system type. The labels shown above are utilising the default labels, but it's possible to set some custom labels in the form of a key-value pair.

### The Cluster Operator

The cluster version operator is the core of what defines an OpenShift deployment . The cluster version operator pod(s) contains the set of manifests which are used to deploy, updated, and/or manage the OpenShift services in the cluster. This operator ensures that the other services, also deployed as operators, are at the version which matches the release definition and takes action to remedy discrepancies when necessary.

```
$ oc get deployments -n openshift-cluster-version
```

```
NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
cluster-version-operator   1         1         1            1           2h
....
```

You can also view the current version of the OpenShift cluster and give you a high-level indication of the status:

```
$ oc get clusterversion
```

```
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.2.14     True        False         14h     Cluster version is 4.2.14
```

If you want to review a list of operators that the cluster version operator is controlling, along with their status, you can ask for a list of the cluster operators:

```
$ oc get clusteroperator
```

```
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
authentication                             4.2.14     True        False         False      15h
cloud-credential                           4.2.14     True        False         False      15h
cluster-autoscaler                         4.2.14     True        False         False      15h
console                                    4.2.14     True        False         False      15h
dns                                        4.2.14     True        False         False      15h
image-registry                             4.2.14     True        False         False      14h
ingress                                    4.2.14     True        False         False      15h
insights                                   4.2.14     True        False         False      15h
kube-apiserver                             4.2.14     True        False         False      15h
kube-controller-manager                    4.2.14     True        False         False      15h
kube-scheduler                             4.2.14     True        False         False      15h
machine-api                                4.2.14     True        False         False      15h
machine-config                             4.2.14     True        False         False      15h
marketplace                                4.2.14     True        False         False      15h
monitoring                                 4.2.14     True        False         False      14h
network                                    4.2.14     True        False         False      15h
node-tuning                                4.2.14     True        False         False      15h
openshift-apiserver                        4.2.14     True        False         False      15h
openshift-controller-manager               4.2.14     True        False         False      15h
openshift-samples                          4.2.14     True        False         False      15h
operator-lifecycle-manager                 4.2.14     True        False         False      15h
operator-lifecycle-manager-catalog         4.2.14     True        False         False      15h
operator-lifecycle-manager-packageserver   4.2.14     True        False         False      15h
service-ca                                 4.2.14     True        False         False      15h
service-catalog-apiserver                  4.2.14     True        False         False      15h
service-catalog-controller-manager         4.2.14     True        False         False      15h
storage                                    4.2.14     True        False         False      15h
```

Or a more comprehensive way of getting a list of operators running on the cluster, along with the link to the code, the documentation, and the commit that provided the functionality is as follows:

```
$ oc adm release info --commits
```

```
Name:          4.2.14
Digest:        sha256:4bf307b98beba4d42da3316464013eac120c6e5a398646863ef92b0e2c621230
Created:       2019-11-21T09:36:15Z
OS/Arch:       linux/amd64
Manifests:     324
Unknown files: 4

Pull From: quay.io/openshift-release-dev/ocp-release@sha256:4bf307b98beba4d42da3316464013eac120c6e5a398646863ef92b0e2c621230

Release Metadata:
  Version:  4.2.14
  Upgrades: 4.1.24, 4.2.0, 4.2.2, 4.2.4, 4.2.7
  Metadata:
    description: 
  Metadata:
    url: https://access.redhat.com/errata/RHBA-2019:3919

Component Versions:
  Kubernetes 1.14.6

Images:
  NAME                                          REPO                                                                       COMMIT 
  aws-machine-controllers                       https://github.com/openshift/cluster-api-provider-aws                      d77b7ae80f23ce511c620f095e8d10844929311c
  azure-machine-controllers                     https://github.com/openshift/cluster-api-provider-azure                    719f40a46924bb1a46143a8df291b33ec17075b8
  baremetal-installer                           https://github.com/openshift/installer                                     425e4ff0037487e32571258640b39f56d5ee5572
  baremetal-machine-controllers                 https://github.com/openshift/cluster-api-provider-baremetal                a2a477909c1d518ef7cf28601e5d7db56a4d4069
  baremetal-operator                            https://github.com/openshift/baremetal-operator                            7869f83d0e93fdb9c589eaf66b7d459d67b39f83
  baremetal-runtimecfg                          https://github.com/openshift/baremetal-runtimecfg                          d5bb4c0889ee6c57675def821103f42f6eefcd35
  cli                                           https://github.com/openshift/oc                                            420c3d6212a959907360fb0b6545f2f0ab173271
  cli-artifacts                                 https://github.com/openshift/oc                                            420c3d6212a959907360fb0b6545f2f0ab173271
  cloud-credential-operator                     https://github.com/openshift/cloud-credential-operator                     b905f49fd022cdc6674a85fa4bcf0f423128831b
  cluster-authentication-operator               https://github.com/openshift/cluster-authentication-operator               64fc3691e84c60d7e395c9f3c7d1653bcbe78604
  cluster-autoscaler                            https://github.com/openshift/kubernetes-autoscaler                         c44b83dacbdd3dc6bc051c96a1b0d6f6865c685b
  cluster-autoscaler-operator                   https://github.com/openshift/cluster-autoscaler-operator                   045aea45264c5d47ccfdc924906f43a016eab169
  cluster-bootstrap                             https://github.com/openshift/cluster-bootstrap                             106f76b4d183cc24e58d26b3b57b2bf1e2362a9d
  cluster-config-operator                       https://github.com/openshift/cluster-config-operator                       7e4895c7e79826566b0bcfab724b8b21cecc597d
  cluster-dns-operator                          https://github.com/openshift/cluster-dns-operator                          b751e751a3a421a3039eeb25b2859dc5f17cc679
  cluster-image-registry-operator               https://github.com/openshift/cluster-image-registry-operator               8743c75acda13f0033002d897129d7756b92d655
  cluster-ingress-operator                      https://github.com/openshift/cluster-ingress-operator                      2a6afceeef9e96bf586bcc8effe57c7e45c3ecd0
  cluster-kube-apiserver-operator               https://github.com/openshift/cluster-kube-apiserver-operator               2515807cd5baf006944df47595deaba12a3a08e5
  cluster-kube-controller-manager-operator      https://github.com/openshift/cluster-kube-controller-manager-operator      1525b57ebafdec3d15886ec47e4efa5bfeb34e69
  cluster-kube-scheduler-operator               https://github.com/openshift/cluster-kube-scheduler-operator               a42fcb7538e6fecad9278d650b04aced7c4e88be
  cluster-machine-approver                      https://github.com/openshift/cluster-machine-approver                      a4a28b0e09ea04592319782a9fb9398aa9569934
  cluster-monitoring-operator                   https://github.com/openshift/cluster-monitoring-operator                   7e2d7841ff7ba5532c9662cba1b1103b04bf3990
  cluster-network-operator                      https://github.com/openshift/cluster-network-operator                      63b0cb389ac17cfcaabd77b957d5b0d9287842b1
  cluster-node-tuned                            https://github.com/openshift/openshift-tuned                               eeaa972122468e5521344d3d88e18565f308c304
  cluster-node-tuning-operator                  https://github.com/openshift/cluster-node-tuning-operator                  02247d0c731236178aa228816e03ee4357c67de9
  cluster-openshift-apiserver-operator          https://github.com/openshift/cluster-openshift-apiserver-operator          76ae60eb1baa4496a5097c3be282873f99ea70d3
  cluster-openshift-controller-manager-operator https://github.com/openshift/cluster-openshift-controller-manager-operator 377cff19428838c0b2c4fbde762e535471922a92
  cluster-samples-operator                      https://github.com/openshift/cluster-samples-operator                      533c9993c23611f26a3d26aecef037b93547e2f9
  cluster-storage-operator                      https://github.com/openshift/cluster-storage-operator                      7c627a01ca2b85f5dfdd901950398c697e3c87e9
  cluster-svcat-apiserver-operator              https://github.com/openshift/cluster-svcat-apiserver-operator              f8b8b5b355d0b525d25600fe8713297be0a3e8bf
  cluster-svcat-controller-manager-operator     https://github.com/openshift/cluster-svcat-controller-manager-operator     9ef3f62c4b3d7b824c9b0b86c2081d694faff5ea
  cluster-update-keys                           https://github.com/openshift/cluster-update-keys                           cca4ce696383e70ae669e770bd63265a9540b721
  cluster-version-operator                      https://github.com/openshift/cluster-version-operator                      e5e468961b5fd687f65844d511690d7ed0046447
  configmap-reloader                            https://github.com/openshift/configmap-reload                              841b0bfe743999fcc9b0528ea689f728eb92aee7
  console                                       https://github.com/openshift/console                                       cbd9bbd69dbca55b17f019eea4e7332f2b40cf0b
  console-operator                              https://github.com/openshift/console-operator                              d6f670515cab5f7e4b56c161aad47515ad6a45f8
  container-networking-plugins                  https://github.com/openshift/containernetworking-plugins                   b5e1059a79397ef886a8047cb4c61919c787f5f5
  coredns                                       https://github.com/openshift/coredns                                       51569b24b4a92d6d8df2020c2e8e2866c5e78266
  deployer                                      https://github.com/openshift/oc                                            420c3d6212a959907360fb0b6545f2f0ab173271
  docker-builder                                https://github.com/openshift/builder                                       2f99856fb715f9ae1584a996ddef0770d3952167
  docker-registry                               https://github.com/openshift/image-registry                                e3d24d9b1b9719423109805e93a82285db761827
  etcd                                          https://github.com/openshift/etcd                                          3ebe3d9fa2302e5ae4712781caac61fc12d5f7f9
  gcp-machine-controllers                       https://github.com/openshift/cluster-api-provider-gcp                      602750a8c1762faf052124fc400b9342514ed8f3
  grafana                                       https://github.com/openshift/grafana                                       91b439eee0cf1ac742ef63cf2a8f7fc9ea3e1432
  haproxy-router                                https://github.com/openshift/router                                        9072754a0a4c311b0e5ac8a9707e692a9b4f7156
  hyperkube                                     https://github.com/openshift/ose                                           6ac6aa4b0fce97d28a292927555522f60291782b
  insights-operator                             https://github.com/openshift/insights-operator                             27768551b735b1cd6a4c9363db8b71a2a2b5c471
  installer                                     https://github.com/openshift/installer                                     425e4ff0037487e32571258640b39f56d5ee5572
  installer-artifacts                           https://github.com/openshift/installer                                     425e4ff0037487e32571258640b39f56d5ee5572
  ironic                                        https://github.com/openshift/ironic-image                                  246346b5f7fb8f871ab61f6a49f820f84bda9d2f
  ironic-inspector                              https://github.com/openshift/ironic-inspector-image                        b83630cefa1a72b2d8ce03c9701acb4f117ab6f5
  ironic-ipa-downloader                         https://github.com/openshift/ironic-ipa-downloader                         b1a144985e413d0c7f3d66bf8f47ecf14e8d617d
  ironic-rhcos-downloader                       https://github.com/openshift/ironic-rhcos-downloader                       93c9e1c5cf83e25487933e46d5aadbe1c68dfea5
  ironic-static-ip-manager                      https://github.com/openshift/ironic-static-ip-manager                      e33314bda6f366472a2371c5598ff2d7dba111c8
  jenkins                                       https://github.com/openshift/jenkins                                       e13fbe9ff385ff29f7627aecbfb0727bbfe2d565
  jenkins-agent-maven                           https://github.com/openshift/jenkins                                       e13fbe9ff385ff29f7627aecbfb0727bbfe2d565
  jenkins-agent-nodejs                          https://github.com/openshift/jenkins                                       e13fbe9ff385ff29f7627aecbfb0727bbfe2d565
  k8s-prometheus-adapter                        https://github.com/openshift/k8s-prometheus-adapter                        9c5a42a3fb4bd2adfa24fc10292a36becc669e1e
  keepalived-ipfailover                         https://github.com/openshift/images                                        1be922de56a99f4e254eb9c2fc42d30e5596cf77
  kube-client-agent                             https://github.com/openshift/kubecsr                                       227189dae8e64eca5ad13a8bb96df8d8d5502f35
  kube-etcd-signer-server                       https://github.com/openshift/kubecsr                                       227189dae8e64eca5ad13a8bb96df8d8d5502f35
  kube-proxy                                    https://github.com/openshift/sdn                                           a8140cc16f57414529bde1d8a010ec6a4292bead
  kube-rbac-proxy                               https://github.com/openshift/kube-rbac-proxy                               2658b2444b9992ea474177c73ca9f40f68f04304
  kube-state-metrics                            https://github.com/openshift/kube-state-metrics                            07b29740ca81f5ddf527b8eb700247f7be4474a8
  kuryr-cni                                     https://github.com/openshift/kuryr-kubernetes                              87d0a1bf2af11636cef2089f4e575a1fbb5db6af
  kuryr-controller                              https://github.com/openshift/kuryr-kubernetes                              87d0a1bf2af11636cef2089f4e575a1fbb5db6af
  libvirt-machine-controllers                   https://github.com/openshift/cluster-api-provider-libvirt                  8bf0d9472acb65f1c5134d847f6a5f7e5258a5b3
  local-storage-static-provisioner              https://github.com/openshift/sig-storage-local-static-provisioner          da340b475eb847c17cefe2f2f9bf9be1a3382d4a
  machine-api-operator                          https://github.com/openshift/machine-api-operator                          474e14e4965a8c5e6788417c851ccc7fad1acb3a
  machine-config-operator                       https://github.com/openshift/machine-config-operator                       55bb5fc17da0c3d76e4ee6a55732f0cba93e8520
  machine-os-content                                                                                                       
  mdns-publisher                                https://github.com/openshift/mdns-publisher                                b02f19c5243c9a3ef41eafc41e9d90a24adc0f60
  multus-admission-controller                   https://github.com/openshift/multus-admission-controller                   ccd6c61c10aaa02c31a2053a1a6ac587cee6abb6
  multus-cni                                    https://github.com/openshift/multus-cni                                    d3a1815632cc3e1c7beb10165f960b4708d097fa
  must-gather                                   https://github.com/openshift/must-gather                                   318faeffd87d70d6727fd4cb30da28aab7c87da3
  node                                          https://github.com/openshift/sdn                                           a8140cc16f57414529bde1d8a010ec6a4292bead
  oauth-proxy                                   https://github.com/openshift/oauth-proxy                                   104fe17337fb627194e0848d2907a73016fef000
  oauth-server                                  https://github.com/openshift/oauth-server                                  3ac077fa8097fb851532453fa6e772e1dcfcb3bb
  openshift-apiserver                           https://github.com/openshift/openshift-apiserver                           55d971b2b5aa43b2ae45fed148cf73c149ca79a7
  openshift-controller-manager                  https://github.com/openshift/openshift-controller-manager                  76900b07c76cb81079d1421ac650c0d04c69a48f
  openshift-state-metrics                       https://github.com/openshift/openshift-state-metrics                       c01d2de651071389d2621c46e934fd9cb2bf4b8d
  openstack-machine-controllers                 https://github.com/openshift/cluster-api-provider-openstack                52a3e249a7053149b08374fd989fd5543d3bdcbd
  operator-lifecycle-manager                    https://github.com/operator-framework/operator-lifecycle-manager           34c5c301b63d0d086ea5aa3153bb6c876ecd7ea8
  operator-marketplace                          https://github.com/operator-framework/operator-marketplace                 906bffd1dea6464efd9d73d42f03d411ef6cb158
  operator-registry                             https://github.com/operator-framework/operator-registry                    98ebd3400de159c019b864c6ef7c17eb426d9698
  ovn-kubernetes                                https://github.com/openshift/ovn-kubernetes                                2838bf96025aa08e0472c016294ce425b2ff15df
  pod                                           https://github.com/openshift/images                                        1be922de56a99f4e254eb9c2fc42d30e5596cf77
  prom-label-proxy                              https://github.com/openshift/prom-label-proxy                              dd9a418af5835ddb1a5181ae6f1303f86d8b1ef3
  prometheus                                    https://github.com/openshift/prometheus                                    52650c0fd84e82e20b5dcfa283c69a9e7ada16cb
  prometheus-alertmanager                       https://github.com/openshift/prometheus-alertmanager                       6858fa0f51a7d37db0bb7ff7497aaeef3333f18b
  prometheus-config-reloader                    https://github.com/openshift/prometheus-operator                           38109e45e3a6de5243de6ec45067402b67726c95
  prometheus-node-exporter                      https://github.com/openshift/node_exporter                                 177a938ce401c3928a025fc1fd2ea1ca0ce1c230
  prometheus-operator                           https://github.com/openshift/prometheus-operator                           38109e45e3a6de5243de6ec45067402b67726c95
  sdn-controller                                https://github.com/openshift/sdn                                           a8140cc16f57414529bde1d8a010ec6a4292bead
  service-ca-operator                           https://github.com/openshift/service-ca-operator                           f6720573b9b63147436374e51e6fda44683b1e9f
  service-catalog                               https://github.com/openshift/service-catalog                               7d8b2a29d2e6f1daa81b9b788c944f07cf3513e1
  telemeter                                     https://github.com/openshift/telemeter                                     3308c2642bfb673cb6bb61d8e120436675c06c13
  tests                                         https://github.com/openshift/ose                                           6ac6aa4b0fce97d28a292927555522f60291782b
```

We can also rsh (remote shell access) into the running Operator and see the various manifests associated with the installed release of OpenShift:

```
 $ oc rsh -n openshift-cluster-version deployments/cluster-version-operator
....
```

Then to list the available manifests:

```
ls -l /release-manifests/

sh-4.2# ls -l /release-manifests/
total 3100
-r--r--r--. 1 root root  33433 Nov 19 17:07 0000_03_authorization-openshift_01_rolebindingrestriction.crd.yaml
-r--r--r--. 1 root root  27823 Nov 19 17:07 0000_03_config-operator_01_operatorhub.crd.yaml
-r--r--r--. 1 root root  27696 Nov 19 17:07 0000_03_config-operator_01_proxy.crd.yaml
-r--r--r--. 1 root root  33644 Nov 19 17:07 0000_03_quota-openshift_01_clusterresourcequota.crd.yaml
-r--r--r--. 1 root root    331 Nov 19 17:07 0000_03_quota-openshift_01_clusterresourcequota.crd.yaml-merge-patch
-r--r--r--. 1 root root  37401 Nov 19 17:07 0000_03_security-openshift_01_scc.crd.yaml
-r--r--r--. 1 root root    146 Nov 19 17:07 0000_05_config-operator_02_apiserver.cr.yaml
-r--r--r--. 1 root root    151 Nov 19 17:07 0000_05_config-operator_02_authentication.cr.yaml
-r--r--r--. 1 root root    142 Nov 19 17:07 0000_05_config-operator_02_build.cr.yaml
-r--r--r--. 1 root root    144 Nov 19 17:07 0000_05_config-operator_02_console.cr.yaml
-r--r--r--. 1 root root    140 Nov 19 17:07 0000_05_config-operator_02_dns.cr.yaml
-r--r--r--. 1 root root    148 Nov 19 17:07 0000_05_config-operator_02_featuregate.cr.yaml
-r--r--r--. 1 root root    142 Nov 19 17:07 0000_05_config-operator_02_image.cr.yaml
-r--r--r--. 1 root root    151 Nov 19 17:07 0000_05_config-operator_02_infrastructure.cr.yaml
-r--r--r--. 1 root root    144 Nov 19 17:07 0000_05_config-operator_02_ingress.cr.yaml
-r--r--r--. 1 root root    144 Nov 19 17:07 0000_05_config-operator_02_network.cr.yaml
-r--r--r--. 1 root root    142 Nov 19 17:07 0000_05_config-operator_02_oauth.cr.yaml
-r--r--r--. 1 root root    148 Nov 19 17:07 0000_05_config-operator_02_operatorhub.cr.yaml
-r--r--r--. 1 root root    144 Nov 19 17:07 0000_05_config-operator_02_project.cr.yaml
-r--r--r--. 1 root root    142 Nov 19 17:07 0000_05_config-operator_02_proxy.cr.yaml
-r--r--r--. 1 root root    146 Nov 19 17:07 0000_05_config-operator_02_scheduler.cr.yaml
-r--r--r--. 1 root root  28878 Nov 19 17:07 0000_10_config-operator_01_apiserver.crd.yaml
-r--r--r--. 1 root root  29540 Nov 19 17:07 0000_10_config-operator_01_authentication.crd.yaml
-r--r--r--. 1 root root  43343 Nov 19 17:07 0000_10_config-operator_01_build.crd.yaml
-r--r--r--. 1 root root  26292 Nov 19 17:07 0000_10_config-operator_01_console.crd.yaml
-r--r--r--. 1 root root  28406 Nov 19 17:07 0000_10_config-operator_01_dns.crd.yaml
-r--r--r--. 1 root root  26327 Nov 19 17:07 0000_10_config-operator_01_featuregate.crd.yaml
-r--r--r--. 1 root root  30369 Nov 19 17:07 0000_10_config-operator_01_image.crd.yaml
-r--r--r--. 1 root root  27897 Nov 19 17:07 0000_10_config-operator_01_imagecontentsourcepolicy.crd.yaml
-r--r--r--. 1 root root  33411 Nov 19 17:07 0000_10_config-operator_01_infrastructure.crd.yaml
-r--r--r--. 1 root root  25479 Nov 19 17:07 0000_10_config-operator_01_ingress.crd.yaml
-r--r--r--. 1 root root  29666 Nov 19 17:07 0000_10_config-operator_01_network.crd.yaml
-r--r--r--. 1 root root  60289 Nov 19 17:07 0000_10_config-operator_01_oauth.crd.yaml
-r--r--r--. 1 root root    166 Nov 19 17:07 0000_10_config-operator_01_openshift-config-managed-ns.yaml
-r--r--r--. 1 root root    158 Nov 19 17:07 0000_10_config-operator_01_openshift-config-ns.yaml
-r--r--r--. 1 root root  25690 Nov 19 17:07 0000_10_config-operator_01_project.crd.yaml
-r--r--r--. 1 root root  27659 Nov 19 17:07 0000_10_config-operator_01_scheduler.crd.yaml
-r--r--r--. 1 root root    538 Nov 19 17:07 0000_10_config-operator_02_config.clusterrole.yaml
-r--r--r--. 1 root root  33579 Nov 19 17:07 0000_10_quota-openshift_01_clusterresourcequota.crd.yaml
-r--r--r--. 1 root root    219 Nov 19 17:09 0000_20_kube-apiserver-operator_00_namespace.yaml
-r--r--r--. 1 root root  32073 Nov 19 17:09 0000_20_kube-apiserver-operator_01_config.crd.yaml
-r--r--r--. 1 root root    176 Nov 19 17:09 0000_20_kube-apiserver-operator_01_operator.cr.yaml
-r--r--r--. 1 root root    425 Nov 19 17:09 0000_20_kube-apiserver-operator_02_service.yaml
-r--r--r--. 1 root root    223 Nov 19 17:09 0000_20_kube-apiserver-operator_03_configmap.yaml
-r--r--r--. 1 root root    297 Nov 19 17:09 0000_20_kube-apiserver-operator_04_clusterrolebinding.yaml
-r--r--r--. 1 root root    169 Nov 19 17:09 0000_20_kube-apiserver-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root   2532 Nov 19 17:09 0000_20_kube-apiserver-operator_06_deployment.yaml
-r--r--r--. 1 root root    250 Nov 19 17:09 0000_20_kube-apiserver-operator_07_clusteroperator.yaml
-r--r--r--. 1 root root    228 Nov 19 17:11 0000_25_kube-controller-manager-operator_00_namespace.yaml
-r--r--r--. 1 root root  32176 Nov 19 17:11 0000_25_kube-controller-manager-operator_01_config.crd.yaml
-r--r--r--. 1 root root    329 Nov 19 17:11 0000_25_kube-controller-manager-operator_01_config.crd.yaml-merge-patch
-r--r--r--. 1 root root    183 Nov 19 17:11 0000_25_kube-controller-manager-operator_01_operator.cr.yaml
-r--r--r--. 1 root root    461 Nov 19 17:11 0000_25_kube-controller-manager-operator_02_service.yaml
-r--r--r--. 1 root root    241 Nov 19 17:11 0000_25_kube-controller-manager-operator_03_configmap.yaml
-r--r--r--. 1 root root    324 Nov 19 17:11 0000_25_kube-controller-manager-operator_04_clusterrolebinding.yaml
-r--r--r--. 1 root root    143 Nov 19 17:11 0000_25_kube-controller-manager-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root   2631 Nov 19 17:11 0000_25_kube-controller-manager-operator_06_deployment.yaml
-r--r--r--. 1 root root    280 Nov 19 17:11 0000_25_kube-controller-manager-operator_07_clusteroperator.yaml
-r--r--r--. 1 root root    219 Nov 19 17:09 0000_25_kube-scheduler-operator_00_namespace.yaml
-r--r--r--. 1 root root  32122 Nov 19 17:09 0000_25_kube-scheduler-operator_01_config.crd.yaml
-r--r--r--. 1 root root    329 Nov 19 17:09 0000_25_kube-scheduler-operator_01_config.crd.yaml-merge-patch
-r--r--r--. 1 root root    176 Nov 19 17:09 0000_25_kube-scheduler-operator_02_operator.cr.yaml
-r--r--r--. 1 root root    445 Nov 19 17:09 0000_25_kube-scheduler-operator_02_service.yaml
-r--r--r--. 1 root root    233 Nov 19 17:09 0000_25_kube-scheduler-operator_03_configmap.yaml
-r--r--r--. 1 root root    315 Nov 19 17:09 0000_25_kube-scheduler-operator_04_clusterrolebinding.yaml
-r--r--r--. 1 root root    188 Nov 19 17:09 0000_25_kube-scheduler-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root   2493 Nov 19 17:09 0000_25_kube-scheduler-operator_06_deployment.yaml
-r--r--r--. 1 root root    250 Nov 19 17:09 0000_25_kube-scheduler-operator_07_clusteroperator.yaml
-r--r--r--. 1 root root   2287 Nov 19 17:08 0000_30_machine-api-operator_00_credentials-request.yaml
-r--r--r--. 1 root root    326 Nov 19 17:08 0000_30_machine-api-operator_00_namespace.yaml
-r--r--r--. 1 root root   2162 Nov 19 17:08 0000_30_machine-api-operator_01_images.configmap.yaml
-r--r--r--. 1 root root   9617 Nov 19 17:08 0000_30_machine-api-operator_02_machine.crd.yaml
-r--r--r--. 1 root root   9890 Nov 19 17:08 0000_30_machine-api-operator_03_machineset.crd.yaml
-r--r--r--. 1 root root   1958 Nov 19 17:08 0000_30_machine-api-operator_07_machinehealthcheck.crd.yaml
-r--r--r--. 1 root root   5267 Nov 19 17:08 0000_30_machine-api-operator_08_machinedisruptionbudget.crd.yaml
-r--r--r--. 1 root root   5557 Nov 19 17:08 0000_30_machine-api-operator_09_rbac.yaml
-r--r--r--. 1 root root    329 Nov 19 17:08 0000_30_machine-api-operator_10_service.yaml
-r--r--r--. 1 root root   1982 Nov 19 17:08 0000_30_machine-api-operator_11_deployment.yaml
-r--r--r--. 1 root root    160 Nov 19 17:08 0000_30_machine-api-operator_12_clusteroperator.yaml
-r--r--r--. 1 root root  14165 Nov 19 17:08 0000_30_machine-api-operator_13_baremetalhost.crd.yaml
-r--r--r--. 1 root root    214 Nov 19 17:11 0000_30_openshift-apiserver-operator_00_namespace.yaml
-r--r--r--. 1 root root  29172 Nov 19 17:11 0000_30_openshift-apiserver-operator_01_config.crd.yaml
-r--r--r--. 1 root root    180 Nov 19 17:11 0000_30_openshift-apiserver-operator_01_operator.cr.yaml
-r--r--r--. 1 root root    223 Nov 19 17:11 0000_30_openshift-apiserver-operator_03_configmap.yaml
-r--r--r--. 1 root root    235 Nov 19 17:11 0000_30_openshift-apiserver-operator_03_trusted_ca_cm.yaml
-r--r--r--. 1 root root    302 Nov 19 17:11 0000_30_openshift-apiserver-operator_04_roles.yaml
-r--r--r--. 1 root root    173 Nov 19 17:11 0000_30_openshift-apiserver-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root    412 Nov 19 17:11 0000_30_openshift-apiserver-operator_06_service.yaml
-r--r--r--. 1 root root   2467 Nov 19 17:11 0000_30_openshift-apiserver-operator_07_deployment.yaml
-r--r--r--. 1 root root    168 Nov 19 17:11 0000_30_openshift-apiserver-operator_08_clusteroperator.yaml
-r--r--r--. 1 root root    337 Nov 19 17:15 0000_50_cloud-credential-operator_00_clusterreader_clusterrole.yaml
-r--r--r--. 1 root root   4129 Nov 19 17:15 0000_50_cloud-credential-operator_00_v1_crd.yaml
-r--r--r--. 1 root root   4554 Nov 19 17:15 0000_50_cloud-credential-operator_01_deployment.yaml
-r--r--r--. 1 root root    576 Nov 19 17:15 0000_50_cloud-credential-operator_03_cred-iam-ro.yaml
-r--r--r--. 1 root root    153 Nov 19 17:15 0000_50_cloud-credential-operator_10_cluster-operator.yaml
-r--r--r--. 1 root root    369 Nov 19 17:09 0000_50_cluster-authentication-operator_00_namespace.yaml
-r--r--r--. 1 root root  29111 Nov 19 17:09 0000_50_cluster-authentication-operator_01_config.crd.yaml
-r--r--r--. 1 root root    177 Nov 19 17:09 0000_50_cluster-authentication-operator_02_config.cr.yaml
-r--r--r--. 1 root root    427 Nov 19 17:09 0000_50_cluster-authentication-operator_02_service.yaml
-r--r--r--. 1 root root    238 Nov 19 17:09 0000_50_cluster-authentication-operator_03_configmap.yaml
-r--r--r--. 1 root root    250 Nov 19 17:09 0000_50_cluster-authentication-operator_03_operand_trusted_ca.yaml
-r--r--r--. 1 root root    240 Nov 19 17:09 0000_50_cluster-authentication-operator_03_operator_trusted_ca.yaml
-r--r--r--. 1 root root    402 Nov 19 17:09 0000_50_cluster-authentication-operator_04_roles.yaml
-r--r--r--. 1 root root    315 Nov 19 17:09 0000_50_cluster-authentication-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root 638029 Nov 19 17:09 0000_50_cluster-authentication-operator_06_branding_secret.yaml
-r--r--r--. 1 root root   2899 Nov 19 17:09 0000_50_cluster-authentication-operator_07_deployment.yaml
-r--r--r--. 1 root root    207 Nov 19 17:09 0000_50_cluster-authentication-operator_08_clusteroperator.yaml
-r--r--r--. 1 root root    279 Nov 19 17:08 0000_50_cluster-autoscaler-operator_00_namespace.yaml
-r--r--r--. 1 root root   6833 Nov 19 17:08 0000_50_cluster-autoscaler-operator_01_clusterautoscaler.crd.yaml
-r--r--r--. 1 root root   5567 Nov 19 17:08 0000_50_cluster-autoscaler-operator_02_machineautoscaler.crd.yaml
-r--r--r--. 1 root root   5719 Nov 19 17:08 0000_50_cluster-autoscaler-operator_03_rbac.yaml
-r--r--r--. 1 root root    523 Nov 19 17:08 0000_50_cluster-autoscaler-operator_04_service.yaml
-r--r--r--. 1 root root    245 Nov 19 17:08 0000_50_cluster-autoscaler-operator_05_configmap.yaml
-r--r--r--. 1 root root    482 Nov 19 17:08 0000_50_cluster-autoscaler-operator_06_servicemonitor.yaml
-r--r--r--. 1 root root   2734 Nov 19 17:08 0000_50_cluster-autoscaler-operator_07_deployment.yaml
-r--r--r--. 1 root root    153 Nov 19 17:08 0000_50_cluster-autoscaler-operator_08_clusteroperator.yaml
-r--r--r--. 1 root root  25875 Nov 19 17:15 0000_50_cluster-image-registry-operator_00-crd.yaml
-r--r--r--. 1 root root    217 Nov 19 17:15 0000_50_cluster-image-registry-operator_01-namespace.yaml
-r--r--r--. 1 root root    443 Nov 19 17:15 0000_50_cluster-image-registry-operator_01-registry-credentials-request-azure.yaml
-r--r--r--. 1 root root    506 Nov 19 17:15 0000_50_cluster-image-registry-operator_01-registry-credentials-request-gcs.yaml
-r--r--r--. 1 root root    409 Nov 19 17:15 0000_50_cluster-image-registry-operator_01-registry-credentials-request-openstack.yaml
-r--r--r--. 1 root root   1008 Nov 19 17:15 0000_50_cluster-image-registry-operator_01-registry-credentials-request.yaml
-r--r--r--. 1 root root   1865 Nov 19 17:15 0000_50_cluster-image-registry-operator_02-rbac.yaml
-r--r--r--. 1 root root    128 Nov 19 17:15 0000_50_cluster-image-registry-operator_03-sa.yaml
-r--r--r--. 1 root root    228 Nov 19 17:15 0000_50_cluster-image-registry-operator_04-ca-trusted.yaml
-r--r--r--. 1 root root    549 Nov 19 17:15 0000_50_cluster-image-registry-operator_05-ca-rbac.yaml
-r--r--r--. 1 root root    104 Nov 19 17:15 0000_50_cluster-image-registry-operator_06-ca-serviceaccount.yaml
-r--r--r--. 1 root root   3104 Nov 19 17:15 0000_50_cluster-image-registry-operator_07-operator.yaml
-r--r--r--. 1 root root    162 Nov 19 17:15 0000_50_cluster-image-registry-operator_08-clusteroperator.yaml
-r--r--r--. 1 root root   2290 Nov 19 17:05 0000_50_cluster-ingress-operator_00-cluster-role.yaml
-r--r--r--. 1 root root  26609 Nov 19 17:05 0000_50_cluster-ingress-operator_00-custom-resource-definition-internal.yaml
-r--r--r--. 1 root root  45907 Nov 19 17:05 0000_50_cluster-ingress-operator_00-custom-resource-definition.yaml
-r--r--r--. 1 root root   1464 Nov 19 17:05 0000_50_cluster-ingress-operator_00-ingress-credentials-request.yaml
-r--r--r--. 1 root root    126 Nov 19 17:05 0000_50_cluster-ingress-operator_00-namespace.yaml
-r--r--r--. 1 root root    369 Nov 19 17:05 0000_50_cluster-ingress-operator_01-cluster-role-binding.yaml
-r--r--r--. 1 root root    367 Nov 19 17:05 0000_50_cluster-ingress-operator_01-role-binding.yaml
-r--r--r--. 1 root root    477 Nov 19 17:05 0000_50_cluster-ingress-operator_01-role.yaml
-r--r--r--. 1 root root    196 Nov 19 17:05 0000_50_cluster-ingress-operator_01-service-account.yaml
-r--r--r--. 1 root root   1652 Nov 19 17:05 0000_50_cluster-ingress-operator_02-deployment.yaml
-r--r--r--. 1 root root    348 Nov 19 17:05 0000_50_cluster-ingress-operator_03-cluster-operator.yaml
-r--r--r--. 1 root root    176 Nov 19 16:59 0000_50_cluster-machine-approver_00-ns.yaml
-r--r--r--. 1 root root   1582 Nov 19 16:59 0000_50_cluster-machine-approver_01-rbac.yaml
-r--r--r--. 1 root root   2092 Nov 19 16:59 0000_50_cluster-machine-approver_02-deployment.yaml
-r--r--r--. 1 root root    146 Nov 19 16:57 0000_50_cluster-node-tuning-operator_01-namespace.yaml
-r--r--r--. 1 root root   5567 Nov 19 16:57 0000_50_cluster-node-tuning-operator_02-crd.yaml
-r--r--r--. 1 root root   1900 Nov 19 16:57 0000_50_cluster-node-tuning-operator_03-rbac.yaml
-r--r--r--. 1 root root   2191 Nov 19 16:57 0000_50_cluster-node-tuning-operator_04-operator.yaml
-r--r--r--. 1 root root    159 Nov 19 16:57 0000_50_cluster-node-tuning-operator_05-clusteroperator.yaml
-r--r--r--. 1 root root    223 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_00_namespace.yaml
-r--r--r--. 1 root root    214 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_01_operand-namespace.yaml
-r--r--r--. 1 root root  29221 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_02_config.crd.yaml
-r--r--r--. 1 root root    329 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_02_config.crd.yaml-merge-patch
-r--r--r--. 1 root root    189 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_03_config.cr.yaml
-r--r--r--. 1 root root    241 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_03_configmap.yaml
-r--r--r--. 1 root root    471 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_04_metricservice.yaml
-r--r--r--. 1 root root    413 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_05_builder-deployer-config.yaml
-r--r--r--. 1 root root    329 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_06_roles.yaml
-r--r--r--. 1 root root    200 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_07_serviceaccount.yaml
-r--r--r--. 1 root root   2446 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_09_deployment.yaml
-r--r--r--. 1 root root    177 Nov 19 16:58 0000_50_cluster-openshift-controller-manager-operator_10_clusteroperator.yaml
-r--r--r--. 1 root root  31511 Nov 19 16:52 0000_50_cluster-samples-operator_00-crd.yaml
-r--r--r--. 1 root root    169 Nov 19 16:52 0000_50_cluster-samples-operator_01-namespace.yaml
-r--r--r--. 1 root root    131 Nov 19 16:52 0000_50_cluster-samples-operator_02-sa.yaml
-r--r--r--. 1 root root   1722 Nov 19 16:52 0000_50_cluster-samples-operator_03-rbac.yaml
-r--r--r--. 1 root root    334 Nov 19 16:52 0000_50_cluster-samples-operator_04-openshift-rbac.yaml
-r--r--r--. 1 root root    591 Nov 19 16:52 0000_50_cluster-samples-operator_05-kube-system-rbac.yaml
-r--r--r--. 1 root root   2272 Nov 19 16:52 0000_50_cluster-samples-operator_06-operator.yaml
-r--r--r--. 1 root root    166 Nov 19 16:52 0000_50_cluster-samples-operator_07-clusteroperator.yaml
-r--r--r--. 1 root root   1972 Nov 19 16:52 0000_50_cluster-samples-operator_08-openshift-imagestreams.yaml
-r--r--r--. 1 root root    134 Nov 19 17:06 0000_50_cluster-storage-operator_00-namespace.yaml
-r--r--r--. 1 root root    323 Nov 19 17:06 0000_50_cluster-storage-operator_01-cluster-role-binding.yaml
-r--r--r--. 1 root root    574 Nov 19 17:06 0000_50_cluster-storage-operator_01-cluster-role.yaml
-r--r--r--. 1 root root    309 Nov 19 17:06 0000_50_cluster-storage-operator_01-role-binding.yaml
-r--r--r--. 1 root root    493 Nov 19 17:06 0000_50_cluster-storage-operator_01-role.yaml
-r--r--r--. 1 root root    127 Nov 19 17:06 0000_50_cluster-storage-operator_01-service-account.yaml
-r--r--r--. 1 root root   1984 Nov 19 17:06 0000_50_cluster-storage-operator_02-deployment.yaml
-r--r--r--. 1 root root    143 Nov 19 17:06 0000_50_cluster-storage-operator_03-cluster-operator.yaml
-r--r--r--. 1 root root    154 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_00_namespace.yaml
-r--r--r--. 1 root root  29203 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_02_config.crd.yaml
-r--r--r--. 1 root root    205 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_03_config.cr.yaml
-r--r--r--. 1 root root    255 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_03_configmap.yaml
-r--r--r--. 1 root root    262 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_03_version-configmap.yaml
-r--r--r--. 1 root root    350 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_04_roles.yaml
-r--r--r--. 1 root root    221 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_05_serviceaccount.yaml
-r--r--r--. 1 root root    476 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_06_service.yaml
-r--r--r--. 1 root root   2381 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_07_deployment.yaml
-r--r--r--. 1 root root    174 Nov 19 17:08 0000_50_cluster-svcat-apiserver-operator_08_cluster-operator.yaml
-r--r--r--. 1 root root    207 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_00_namespace.yaml
-r--r--r--. 1 root root  29251 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_02_config.crd.yaml
-r--r--r--. 1 root root    215 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_03_config.cr.yaml
-r--r--r--. 1 root root    273 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_03_configmap.yaml
-r--r--r--. 1 root root    535 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_04_metricservice.yaml
-r--r--r--. 1 root root    377 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_06_roles.yaml
-r--r--r--. 1 root root    248 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_07_serviceaccount.yaml
-r--r--r--. 1 root root   2583 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_09_deployment.yaml
-r--r--r--. 1 root root    182 Nov 19 17:08 0000_50_cluster-svcat-controller-manager-operator_10_cluster-operator.yaml
-r--r--r--. 1 root root    255 Nov 19 17:04 0000_50_cluster_monitoring_operator_01-namespace.yaml
-r--r--r--. 1 root root   5746 Nov 19 17:04 0000_50_cluster_monitoring_operator_02-role.yaml
-r--r--r--. 1 root root    447 Nov 19 17:04 0000_50_cluster_monitoring_operator_03-role-binding.yaml
-r--r--r--. 1 root root   3896 Nov 19 17:04 0000_50_cluster_monitoring_operator_04-deployment.yaml
-r--r--r--. 1 root root    155 Nov 19 17:04 0000_50_cluster_monitoring_operator_05-clusteroperator.yaml
-r--r--r--. 1 root root   1878 Nov 19 17:10 0000_50_console-operator_00-crd-extension-console-cli-download.yaml
-r--r--r--. 1 root root   2159 Nov 19 17:10 0000_50_console-operator_00-crd-extension-console-link.yaml
-r--r--r--. 1 root root   2836 Nov 19 17:10 0000_50_console-operator_00-crd-extension-console-log-link.yaml
-r--r--r--. 1 root root   2089 Nov 19 17:10 0000_50_console-operator_00-crd-extension-console-notification.yaml
-r--r--r--. 1 root root   1545 Nov 19 17:10 0000_50_console-operator_00-crd-operator-config.yaml
-r--r--r--. 1 root root    187 Nov 19 17:10 0000_50_console-operator_01-oauth.yaml
-r--r--r--. 1 root root    170 Nov 19 17:10 0000_50_console-operator_01-operator-config.yaml
-r--r--r--. 1 root root    301 Nov 19 17:10 0000_50_console-operator_02-namespace.yaml
-r--r--r--. 1 root root    389 Nov 19 17:10 0000_50_console-operator_03-rbac-role-cluster-extensions.yaml
-r--r--r--. 1 root root    802 Nov 19 17:10 0000_50_console-operator_03-rbac-role-cluster.yaml
-r--r--r--. 1 root root    923 Nov 19 17:10 0000_50_console-operator_03-rbac-role-ns-console.yaml
-r--r--r--. 1 root root    555 Nov 19 17:10 0000_50_console-operator_03-rbac-role-ns-openshift-config-managed.yaml
-r--r--r--. 1 root root    234 Nov 19 17:10 0000_50_console-operator_03-rbac-role-ns-openshift-config.yaml
-r--r--r--. 1 root root    453 Nov 19 17:10 0000_50_console-operator_03-rbac-role-ns-operator.yaml
-r--r--r--. 1 root root   1106 Nov 19 17:10 0000_50_console-operator_04-rbac-rolebinding-cluster.yaml
-r--r--r--. 1 root root   1883 Nov 19 17:10 0000_50_console-operator_04-rbac-rolebinding.yaml
-r--r--r--. 1 root root    164 Nov 19 17:10 0000_50_console-operator_05-config-public.yaml
-r--r--r--. 1 root root    290 Nov 19 17:10 0000_50_console-operator_05-config.yaml
-r--r--r--. 1 root root    416 Nov 19 17:10 0000_50_console-operator_05-service.yaml
-r--r--r--. 1 root root    111 Nov 19 17:10 0000_50_console-operator_06-sa.yaml
-r--r--r--. 1 root root   4022 Nov 19 17:10 0000_50_console-operator_07-downloads-deployment.yaml
-r--r--r--. 1 root root    280 Nov 19 17:10 0000_50_console-operator_07-downloads-route.yaml
-r--r--r--. 1 root root    224 Nov 19 17:10 0000_50_console-operator_07-downloads-service.yaml
-r--r--r--. 1 root root   2170 Nov 19 17:10 0000_50_console-operator_07-operator.yaml
-r--r--r--. 1 root root    156 Nov 19 17:10 0000_50_console-operator_08-clusteroperator.yaml
-r--r--r--. 1 root root    139 Nov 19 16:59 0000_50_insights-operator_02-namespace.yaml
-r--r--r--. 1 root root   3330 Nov 19 16:59 0000_50_insights-operator_03-clusterrole.yaml
-r--r--r--. 1 root root    224 Nov 19 16:59 0000_50_insights-operator_04-proxy-cert-configmap.yaml
-r--r--r--. 1 root root    192 Nov 19 16:59 0000_50_insights-operator_04-serviceaccount.yaml
-r--r--r--. 1 root root   2136 Nov 19 16:59 0000_50_insights-operator_05-deployment.yaml
-r--r--r--. 1 root root    153 Nov 19 16:59 0000_50_insights-operator_06-cluster-operator.yaml
-r--r--r--. 1 root root    399 Nov 19 17:06 0000_50_olm_00-namespace.yaml
-r--r--r--. 1 root root    743 Nov 19 17:06 0000_50_olm_01-olm-operator.serviceaccount.yaml
-r--r--r--. 1 root root    814 Nov 19 17:06 0000_50_olm_02-services.yaml
-r--r--r--. 1 root root  35382 Nov 19 17:06 0000_50_olm_03-clusterserviceversion.crd.yaml
-r--r--r--. 1 root root   2095 Nov 19 17:06 0000_50_olm_04-installplan.crd.yaml
-r--r--r--. 1 root root   9270 Nov 19 17:06 0000_50_olm_05-subscription.crd.yaml
-r--r--r--. 1 root root   4403 Nov 19 17:06 0000_50_olm_06-catalogsource.crd.yaml
-r--r--r--. 1 root root   2608 Nov 19 17:06 0000_50_olm_07-olm-operator.deployment.yaml
-r--r--r--. 1 root root   2513 Nov 19 17:06 0000_50_olm_08-catalog-operator.deployment.yaml
-r--r--r--. 1 root root   1245 Nov 19 17:06 0000_50_olm_09-aggregated.clusterrole.yaml
-r--r--r--. 1 root root   3269 Nov 19 17:06 0000_50_olm_10-operatorgroup.crd.yaml
-r--r--r--. 1 root root    335 Nov 19 17:06 0000_50_olm_13-operatorgroup-default.yaml
-r--r--r--. 1 root root   4256 Nov 19 17:06 0000_50_olm_15-packageserver.clusterserviceversion.yaml
-r--r--r--. 1 root root    529 Nov 19 17:06 0000_50_olm_99-operatorstatus.yaml
-r--r--r--. 1 root root    189 Nov 19 17:16 0000_50_operator-marketplace_01_namespace.yaml
-r--r--r--. 1 root root   2421 Nov 19 17:16 0000_50_operator-marketplace_02_catalogsourceconfig.crd.yaml
-r--r--r--. 1 root root   3261 Nov 19 17:16 0000_50_operator-marketplace_03_operatorsource.crd.yaml
-r--r--r--. 1 root root    110 Nov 19 17:16 0000_50_operator-marketplace_04_service_account.yaml
-r--r--r--. 1 root root   1735 Nov 19 17:16 0000_50_operator-marketplace_05_role.yaml
-r--r--r--. 1 root root    631 Nov 19 17:16 0000_50_operator-marketplace_06_role_binding.yaml
-r--r--r--. 1 root root    279 Nov 19 17:16 0000_50_operator-marketplace_07_configmap.yaml
-r--r--r--. 1 root root    282 Nov 19 17:16 0000_50_operator-marketplace_08_service.yaml
-r--r--r--. 1 root root   2679 Nov 19 17:16 0000_50_operator-marketplace_09_operator.yaml
-r--r--r--. 1 root root    271 Nov 19 17:16 0000_50_operator-marketplace_10_clusteroperator.yaml
-r--r--r--. 1 root root    922 Nov 19 17:16 0000_50_operator-marketplace_11_service_monitor.yaml
-r--r--r--. 1 root root    689 Nov 19 17:16 0000_50_operator-marketplace_12_prometheus_rule.yaml
-r--r--r--. 1 root root    285 Nov 19 17:08 0000_50_service-ca-operator_00_roles.yaml
-r--r--r--. 1 root root    171 Nov 19 17:08 0000_50_service-ca-operator_01_namespace.yaml
-r--r--r--. 1 root root  29282 Nov 19 17:08 0000_50_service-ca-operator_02_crd.yaml
-r--r--r--. 1 root root    230 Nov 19 17:08 0000_50_service-ca-operator_03_cm.yaml
-r--r--r--. 1 root root    172 Nov 19 17:08 0000_50_service-ca-operator_03_operator.cr.yaml
-r--r--r--. 1 root root    156 Nov 19 17:08 0000_50_service-ca-operator_04_sa.yaml
-r--r--r--. 1 root root   1936 Nov 19 17:08 0000_50_service-ca-operator_05_deploy.yaml
-r--r--r--. 1 root root    240 Nov 19 17:08 0000_50_service-ca-operator_06_config.yaml
-r--r--r--. 1 root root    146 Nov 19 17:08 0000_50_service-ca-operator_07_clusteroperator.yaml
-r--r--r--. 1 root root    205 Nov 19 17:11 0000_70_cluster-network-operator_00_namespace.yaml
-r--r--r--. 1 root root   5249 Nov 19 17:11 0000_70_cluster-network-operator_01_crd.yaml
-r--r--r--. 1 root root    308 Nov 19 17:11 0000_70_cluster-network-operator_02_rbac.yaml
-r--r--r--. 1 root root   3268 Nov 19 17:11 0000_70_cluster-network-operator_03_daemonset.yaml
-r--r--r--. 1 root root    143 Nov 19 17:11 0000_70_cluster-network-operator_04_clusteroperator.yaml
-r--r--r--. 1 root root   1021 Nov 19 17:05 0000_70_dns-operator_00-cluster-role.yaml
-r--r--r--. 1 root root  26415 Nov 19 17:05 0000_70_dns-operator_00-custom-resource-definition.yaml
-r--r--r--. 1 root root    248 Nov 19 17:05 0000_70_dns-operator_00-namespace.yaml
-r--r--r--. 1 root root    353 Nov 19 17:05 0000_70_dns-operator_01-cluster-role-binding.yaml
-r--r--r--. 1 root root    347 Nov 19 17:05 0000_70_dns-operator_01-role-binding.yaml
-r--r--r--. 1 root root    351 Nov 19 17:05 0000_70_dns-operator_01-role.yaml
-r--r--r--. 1 root root    188 Nov 19 17:05 0000_70_dns-operator_01-service-account.yaml
-r--r--r--. 1 root root   1648 Nov 19 17:05 0000_70_dns-operator_02-deployment.yaml
-r--r--r--. 1 root root    339 Nov 19 17:05 0000_70_dns-operator_03-cluster-operator.yaml
-r--r--r--. 1 root root    465 Nov 19 17:11 0000_80_machine-config-operator_00_clusterreader_clusterrole.yaml
-r--r--r--. 1 root root    622 Nov 19 17:11 0000_80_machine-config-operator_00_namespace.yaml
-r--r--r--. 1 root root    948 Nov 19 17:11 0000_80_machine-config-operator_01_mcoconfig.crd.yaml
-r--r--r--. 1 root root   1518 Nov 19 17:11 0000_80_machine-config-operator_02_images.configmap.yaml
-r--r--r--. 1 root root    328 Nov 19 17:11 0000_80_machine-config-operator_03_rbac.yaml
-r--r--r--. 1 root root   1921 Nov 19 17:11 0000_80_machine-config-operator_04_deployment.yaml
-r--r--r--. 1 root root    394 Nov 19 17:11 0000_80_machine-config-operator_05_osimageurl.yaml
-r--r--r--. 1 root root    162 Nov 19 17:11 0000_80_machine-config-operator_06_clusteroperator.yaml
-r--r--r--. 1 root root   2866 Nov 19 17:11 0000_80_machine-config-operator_07_etcdquorumguard_deployment.yaml
-r--r--r--. 1 root root    224 Nov 19 17:11 0000_80_machine-config-operator_08_etcdquorumguard_pdb.yaml
-r--r--r--. 1 root root   1394 Nov 19 17:09 0000_90_cluster-authentication-operator_01_prometheusrbac.yaml
-r--r--r--. 1 root root   1485 Nov 19 17:09 0000_90_cluster-authentication-operator_02_servicemonitor.yaml
-r--r--r--. 1 root root   1071 Nov 19 17:15 0000_90_cluster-image-registry-operator_00_servicemonitor-rbac.yaml
-r--r--r--. 1 root root    576 Nov 19 17:15 0000_90_cluster-image-registry-operator_01_operand-servicemonitor.yaml
-r--r--r--. 1 root root    293 Nov 19 17:08 0000_90_cluster-svcat-apiserver-operator_00_prometheusrole.yaml
-r--r--r--. 1 root root    323 Nov 19 17:08 0000_90_cluster-svcat-apiserver-operator_01_prometheusrolebinding.yaml
-r--r--r--. 1 root root    822 Nov 19 17:08 0000_90_cluster-svcat-apiserver-operator_02-operator-servicemonitor.yaml
-r--r--r--. 1 root root    302 Nov 19 17:08 0000_90_cluster-svcat-controller-manager-operator_00_prometheusrole.yaml
-r--r--r--. 1 root root    332 Nov 19 17:08 0000_90_cluster-svcat-controller-manager-operator_01_prometheusrolebinding.yaml
-r--r--r--. 1 root root    864 Nov 19 17:08 0000_90_cluster-svcat-controller-manager-operator_02_servicemonitor.yaml
-r--r--r--. 1 root root   3976 Nov 19 16:57 0000_90_cluster-update-keys_configmap.yaml
-r--r--r--. 1 root root    436 Nov 19 17:04 0000_90_cluster_monitoring_operator_00-operatorgroup.yaml
-r--r--r--. 1 root root    709 Nov 19 17:10 0000_90_console-operator_01_prometheusrbac.yaml
-r--r--r--. 1 root root    597 Nov 19 17:10 0000_90_console-operator_02_servicemonitor.yaml
-r--r--r--. 1 root root    282 Nov 19 17:09 0000_90_kube-apiserver-operator_01_prometheusrole.yaml
-r--r--r--. 1 root root    312 Nov 19 17:09 0000_90_kube-apiserver-operator_02_prometheusrolebinding.yaml
-r--r--r--. 1 root root   1250 Nov 19 17:09 0000_90_kube-apiserver-operator_03_servicemonitor.yaml
-r--r--r--. 1 root root    960 Nov 19 17:09 0000_90_kube-apiserver-operator_04_servicemonitor-apiserver.yaml
-r--r--r--. 1 root root    291 Nov 19 17:11 0000_90_kube-controller-manager-operator_01_prometheusrole.yaml
-r--r--r--. 1 root root    321 Nov 19 17:11 0000_90_kube-controller-manager-operator_02_prometheusrolebinding.yaml
-r--r--r--. 1 root root    789 Nov 19 17:11 0000_90_kube-controller-manager-operator_03_servicemonitor.yaml
-r--r--r--. 1 root root    731 Nov 19 17:11 0000_90_kube-controller-manager-operator_04_servicemonitor-controller-manager.yaml
-r--r--r--. 1 root root    282 Nov 19 17:09 0000_90_kube-scheduler-operator_01_prometheusrole.yaml
-r--r--r--. 1 root root    312 Nov 19 17:09 0000_90_kube-scheduler-operator_02_prometheusrolebinding.yaml
-r--r--r--. 1 root root    754 Nov 19 17:09 0000_90_kube-scheduler-operator_03_servicemonitor.yaml
-r--r--r--. 1 root root    440 Nov 19 17:09 0000_90_kube-scheduler-operator_04_servicemonitor-scheduler.yaml
-r--r--r--. 1 root root    462 Nov 19 17:08 0000_90_machine-api-operator_03_servicemonitor.yaml
-r--r--r--. 1 root root   1321 Nov 19 17:08 0000_90_machine-api-operator_04_alertrules.yaml
-r--r--r--. 1 root root   2240 Nov 19 17:06 0000_90_olm_00-service-monitor.yaml
-r--r--r--. 1 root root    277 Nov 19 17:11 0000_90_openshift-apiserver-operator_01_prometheusrole.yaml
-r--r--r--. 1 root root    307 Nov 19 17:11 0000_90_openshift-apiserver-operator_02_prometheusrolebinding.yaml
-r--r--r--. 1 root root    742 Nov 19 17:11 0000_90_openshift-apiserver-operator_03_servicemonitor.yaml
-r--r--r--. 1 root root    879 Nov 19 17:11 0000_90_openshift-apiserver-operator_04_servicemonitor-apiserver.yaml
-r--r--r--. 1 root root    286 Nov 19 16:58 0000_90_openshift-controller-manager-operator_00_prometheusrole.yaml
-r--r--r--. 1 root root    316 Nov 19 16:58 0000_90_openshift-controller-manager-operator_01_prometheusrolebinding.yaml
-r--r--r--. 1 root root    703 Nov 19 16:58 0000_90_openshift-controller-manager-operator_02_servicemonitor.yaml
-r--r--r--. 1 root root    602 Nov 19 16:58 0000_90_openshift-controller-manager-operator_03_operand-servicemonitor.yaml
-r--r--r--. 1 root root  63594 Nov 19 17:16 image-references
-r--r--r--. 1 root root    251 Nov 19 17:16 release-metadata
```

We will see a number of .yaml files in this directory; these are manifests that describe each of the operators and how they're applied. Feel free to take a look at some of these to give you an idea of what it's doing:

```
$ cat /release-manifests/0000_50_console-operator_00-crd-operator-config.yaml
```

```
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: consoles.operator.openshift.io
spec:
  scope: Cluster
  group: operator.openshift.io
  names:
    kind: Console
    listKind: ConsoleList
    plural: consoles
    singular: console
  subresources:
    status: {}
  versions:
    - name: v1
      served: true
      storage: true
  validation:
    openAPIV3Schema:
      properties:
        spec:
          properties:
            managementState:
              pattern: ^(Managed|Unmanaged|Removed|Forced)$
              type: string
              description: ManagementState indicates whether and how the operator
                should manage the component
            customization:
              properties:
                documentationBaseURL:
                  pattern: ^$|^((https):\/\/?)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/?))\/$
                  type: string
                  description: Documentation base url can optionally be set but must end in a trailing slash
                brand:
                  pattern: ^$|^(ocp|origin|okd|dedicated|online|azure)$
                  type: string
                  description: Brand may be optionally set to one of six values - azure|dedicated|ocp|okd|online|origin
            providers:
              properties:
                statuspage:
                  properties:
                    pageID:
                      type: string
                      description: Contains ID for statuspage.io page that provides status info about.
```

```
exit
exit
....
```

> NOTE: Don't forget to exit from your rsh session before continuing...

If we want to look at what the cluster operator has done since it was launched, we can execute the following:

```
$ oc logs deployments/cluster-version-operator -n openshift-cluster-version > operatorlog.txt
```

```
[~] $ tail operatorlog.txt
```

```



I1212 12:51:49.032584       1 cvo.go:354] Finished syncing cluster version "openshift-cluster-version/version" (212.863µs)
I1212 12:52:04.032628       1 cvo.go:352] Started syncing cluster version "openshift-cluster-version/version" (2019-12-12 12:52:04.032609397 +0000 UTC m=+54995.288726666)
I1212 12:52:04.032733       1 cvo.go:384] Desired version from operator is v1.Update{Version:"4.2.14", Image:"quay.io/openshift-release-dev/ocp-release@sha256:4bf307b98beba4d42da3316464013eac120c6e5a398646863ef92b0e2c621230", Force:false}
I1212 12:52:04.032895       1 cvo.go:354] Finished syncing cluster version "openshift-cluster-version/version" (279.069µs)
I1212 12:52:19.032340       1 cvo.go:352] Started syncing cluster version "openshift-cluster-version/version" (2019-12-12 12:52:19.0323339 +0000 UTC m=+55010.288451116)
I1212 12:52:19.032443       1 cvo.go:384] Desired version from operator is v1.Update{Version:"4.2.14", Image:"quay.io/openshift-release-dev/ocp-release@sha256:4bf307b98beba4d42da3316464013eac120c6e5a398646863ef92b0e2c621230", Force:false}
I1212 12:52:19.032505       1 cvo.go:354] Finished syncing cluster version "openshift-cluster-version/version" (169.712µs)
I1212 12:52:34.032301       1 cvo.go:352] Started syncing cluster version "openshift-cluster-version/version" (2019-12-12 12:52:34.032295794 +0000 UTC m=+55025.288413009)
I1212 12:52:34.032338       1 cvo.go:384] Desired version from operator is v1.Update{Version:"4.2.14", Image:"quay.io/openshift-release-dev/ocp-release@sha256:4bf307b98beba4d42da3316464013eac120c6e5a398646863ef92b0e2c621230", Force:false}
I1212 12:52:34.032381       1 cvo.go:354] Finished syncing cluster version "openshift-cluster-version/version" (84.011µs)
```

The operator's log is extremely long, so it is recommended that you redirect it to a file instead of trying to look at it directly with the logs command.
