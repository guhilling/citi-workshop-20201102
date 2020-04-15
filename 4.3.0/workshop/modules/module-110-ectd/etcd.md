# ETCD

## Explore etcd

#### etcdclt version

On an OpenShift 4.x cluster the version 3.3.17 is used

```
sh-4.2# etcdctl version 
etcdctl version: 3.3.17
API version: 3.3
```

And the ETCDCTL_API version 3 is used by default
```
sh-4.2# env|grep ETCDCTL_API
ETCDCTL_API=3
```


#### Set the etcdctl environment variables

`In OpenShift 4.x the certificates for the etcd servers are now located in the directory /etc/ssl/etcd/!`


```
sh-4.2# ls -lisa /etc/ssl/etcd
total 44
 89429870 4 drwxr-xr-x. 2 root root 4096 Mar  3 10:33 .
142711695 0 drwxr-xr-x. 1 root root   18 Mar 30 06:22 ..
 89429871 4 -rw-r--r--. 1 root root 1135 Mar  3 10:32 ca.crt
 89429872 4 -rw-r--r--. 1 root root 1151 Mar  3 10:32 metric-ca.crt
 89429873 8 -rw-r--r--. 1 root root 6998 Mar  3 10:32 root-ca.crt
 89429879 4 -rw-r--r--. 1 root root 1537 Mar  3 09:13 system:etcd-metric:etcd-0.ocp4.h12.rhaw.io.crt
 89429878 4 -rw-------. 1 root root 1679 Mar  3 09:13 system:etcd-metric:etcd-0.ocp4.h12.rhaw.io.key
 89429877 4 -rw-r--r--. 1 root root 1367 Mar  3 09:13 system:etcd-peer:etcd-0.ocp4.h12.rhaw.io.crt
 89429876 4 -rw-------. 1 root root 1675 Mar  3 09:13 system:etcd-peer:etcd-0.ocp4.h12.rhaw.io.key
 89429875 4 -rw-r--r--. 1 root root 1537 Mar  3 09:13 system:etcd-server:etcd-0.ocp4.h12.rhaw.io.crt
 89429874 4 -rw-------. 1 root root 1675 Mar  3 09:13 system:etcd-server:etcd-0.ocp4.h12.rhaw.io.key

```
To avoid typing on each etcdctl command the global options --cacert, --cert and --key we'll set the environment variables like this

```
sh-4.2# export ETCDCTL_CACERT=/etc/ssl/etcd/ca.crt ETCDCTL_CERT=$(find /etc/ssl/ -name *peer*crt) ETCDCTL_KEY=$(find /etc/ssl/ -name *peer*key)
```
```
sh-4.2# export ETCDCTL_ENDPOINTS=$(etcdctl member list|cut -d',' -f5|cut -d ' ' -f2|awk 'ORS=","'| head -c -1)
```
`If the etcdctl command expects the list of cluster members add the option --cluster`

#### Get the etcd member list

MEMBER LIST prints the member details for all members associated with an etcd cluster.

```
sh-4.2# etcdctl member list -w table
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
|        ID        | STATUS  |         NAME         |              PEER ADDRS              |        CLIENT ADDRS         |
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
| 570db60db6086170 | started | etcd-member-master02 | https://etcd-1.ocp4.h12.rhaw.io:2380 | https://192.168.100.22:2379 |
| ac4f6a42ebd3adfb | started | etcd-member-master03 | https://etcd-2.ocp4.h12.rhaw.io:2380 | https://192.168.100.23:2379 |
| d241e2cf814e2ec1 | started | etcd-member-master01 | https://etcd-0.ocp4.h12.rhaw.io:2380 | https://192.168.100.21:2379 |
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
```


#### ETCD endpoint status

ENDPOINT STATUS queries the status of each endpoint in the given endpoint list.

```
sh-4.2# etcdctl endpoint status --cluster -w table
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
|               ENDPOINT               |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
| https://etcd-0.ocp4.h12.rhaw.io:2379 | d241e2cf814e2ec1 |  3.3.17 |   69 MB |     false |         8 |     945547 |
| https://etcd-1.ocp4.h12.rhaw.io:2379 | 570db60db6086170 |  3.3.17 |   69 MB |      true |         8 |     945547 |
| https://etcd-2.ocp4.h12.rhaw.io:2379 | ac4f6a42ebd3adfb |  3.3.17 |   70 MB |     false |         8 |     945547 |
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
```

#### ETCD endpoint health

ENDPOINT HEALTH checks the health of the list of endpoints with respect to cluster. An endpoint is unhealthy when it cannot participate in consensus with the rest of the cluster.
If an endpoint can participate in consensus, prints a message indicating the endpoint is healthy. If an endpoint fails to participate in consensus, prints a message indicating the endpoint is unhealthy.

```
sh-4.2# etcdctl endpoint health --cluster -w table
+--------------------------------------+--------+-------------+-------+
|               ENDPOINT               | HEALTH |    TOOK     | ERROR |
+--------------------------------------+--------+-------------+-------+
| https://etcd-2.ocp4.h12.rhaw.io:2379 |   true | 20.306241ms |       |
| https://etcd-0.ocp4.h12.rhaw.io:2379 |   true | 12.822589ms |       |
| https://etcd-1.ocp4.h12.rhaw.io:2379 |   true | 23.781412ms |       |
+--------------------------------------+--------+-------------+-------+
```

#### Get the current existing objects in the etcd database

GET gets the key or a range of keys

To see how many enties are available for each key run:

```
sh-4.2# etcdctl get / --prefix --keys-only | sed '/^$/d' | cut -d/ -f3 | sort | uniq -c | sort -rn         
	950 secrets
	311 configmaps
	261 serviceaccounts
	245 rolebindings
	232 pods
	221 images
	184 clusterroles
	159 clusterrolebindings
	123 templates
	120 services
	 77 roles
	 76 replicasets
	 74 imagestreams
	 74 apiextensions.k8s.io
	 67 apiregistration.k8s.io
	 66 monitoring.coreos.com
	 61 network.openshift.io
	 53 namespaces
	 49 deployments
	 43 config.openshift.io
	 30 controllerrevisions
	 15 machineconfiguration.openshift.io
	 13 operator.openshift.io
	 13 daemonsets
	 13 cloudcredential.openshift.io
	 10 operators.coreos.com
	  8 security.openshift.io
	  7 routes
	  7 minions
	  7 leases
	  6 oauth
	  3 masterleases
	  3 console.openshift.io
	  2 validatingwebhookconfigurations
	  2 users
	  2 useridentities
	  2 statefulsets
	  2 ranges
	  2 priorityclasses
	  2 events
	  1 tuned.openshift.io
	  1 samples.operator.openshift.io
	  1 rangeallocations
	  1 poddisruptionbudgets
	  1 imageregistry.operator.openshift.io
```

### etcd alarms

List all alarms
```
sh-4.2# etcdctl alarm list
```

Disarms all alarms
```
sh-4.2# etcdctl alarm disarm

```


### compact etcd

COMPACTION discards all etcd event history prior to a given revision.

An etcd cluster needs periodic maintenance to remain reliable. Depending on an etcd application's needs, this maintenance can usually be automated and performed without downtime or significantly degraded performance.
All etcd maintenance manages storage resources consumed by the etcd keyspace. Failure to adequately control the keyspace size is guarded by storage space quotas; if an etcd member runs low on space, a quota will trigger cluster-wide alarms which will put the system into a limited-operation maintenance mode. To avoid running out of space for writes to the keyspace, the etcd keyspace history must be compacted. Storage space itself may be reclaimed by defragmenting etcd members. Finally, periodic snapshot backups of etcd member state makes it possible to recover any unintended logical data loss or corruption caused by operational error.

Since etcd keeps an exact history of its keyspace, this history should be periodically compacted to avoid performance degradation and eventual storage space exhaustion. Compacting the keyspace history drops all information about keys superseded prior to a given keyspace revision. The space used by these keys then becomes available for additional writes to the keyspace.
The keyspace can be compacted automatically with `etcd`'s time windowed history retention policy, or manually with `etcdctl`. The `etcdctl` method provides fine-grained control over the compacting process whereas automatic compacting fits applications that only need key history for some length of time.

```
sh-4.2# REVISION=$(etcdctl endpoint status --cluster --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*'| sort -rn| tail -1)
```
```
sh-4.2# etcdctl compaction \
--endpoints=https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
$REVISION
```

### defrag etcd

DEFRAG defragments the backend database file for a set of given endpoints while etcd is running

After compacting the keyspace, the backend database may exhibit internal fragmentation. Any internal fragmentation is space that is free to use by the backend but still consumes storage space. Compacting old revisions internally fragments `etcd` by leaving gaps in backend database. Fragmented space is available for use by `etcd` but unavailable to the host filesystem. In other words, deleting application data does not reclaim the space on disk.

The process of defragmentation releases this storage space back to the file system. Defragmentation is issued on a per-member so that cluster-wide latency spikes may be avoided.

To defragment an etcd member, use the `etcdctl defrag` command:

```sh
sh-4.2# etcdctl defrag
Finished defragmenting etcd member[127.0.0.1:2379]
```

**Note that defragmentation to a live member blocks the system from reading and writing data while rebuilding its states**.

**Note that defragmentation request does not get replicated over cluster. That is, the request is only applied to the local node. Specify all members in --endpoints flag.**

Run defragment operations for all endpoints in the cluster associated with the default endpoint:

```
sh-4.2# etcdctl defrag --endpoints=https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379          
Finished defragmenting etcd member[https://etcd-0.ocp4.h12.rhaw.io:2379]
Finished defragmenting etcd member[https://etcd-1.ocp4.h12.rhaw.io:2379]
Finished defragmenting etcd member[https://etcd-2.ocp4.h12.rhaw.io:2379]
```
For each endpoints, prints a message indicating whether the endpoint was successfully defragmented.
If there are error messages rerun the defrag with only the failed machine mentioned in --endpoints

### create etcd snapshots

SNAPSHOT SAVE writes a point-in-time snapshot of the etcd backend database to a file.

Snapshotting the `etcd` cluster on a regular basis serves as a durable backup for an etcd keyspace. By taking periodic snapshots of an etcd member's backend database, an `etcd` cluster can be recovered to a point in time with a known good state.
A snapshot is taken with `etcdctl`:

```
sh-4.2# etcdctl snapshot save /var/lib/etcd/backup/etcd-$(date +%Y%m%d)/db
{"level":"warn","ts":"2020-02-13T14:22:29.278Z","caller":"clientv3/retry_interceptor.go:116","msg":"retry stream intercept"}
Snapshot saved at /var/lib/etcd/backup/etcd-20200213/db
```

### validate etcd snapshots

SNAPSHOT STATUS lists information about a given backend database snapshot file.

```
sh-4.2# etcdctl snapshot status /var/lib/etcd/backup/etcd-$(date +%Y%m%d)/db -w table
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 196aa56f |   768941 |       5989 |      70 MB |
+----------+----------+------------+------------+
```

### ETCD performance check

There are four different load profiles available (s,m,l and xl)

Profile | write limit | clients
--- | --- |---
s | 150 | 50
m | 1000 | 200
l | 8000 | 500
xl | 15000 | 1000

```
sh-4.2# etcdctl check perf --command-timeout=60s --load="s" --prefix="/etcdctl-check-perf/"
 60 / 60 Boooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00%1m0s
PASS: Throughput is 150 writes/s
PASS: Slowest request took 0.083526s
PASS: Stddev is 0.008879s
PASS
```

### Moving the etcd cluster leadership

MOVE-LEADER transfers leadership from the leader to another member in the cluster.

Check who is the current leader

```
sh-4.2# etcdctl endpoint status --cluster -w table
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
|          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
| https://192.168.100.22:2379 | 570db60db6086170 |  3.3.17 |   37 MB |     false |        12 |   15776619 |
| https://192.168.100.23:2379 | ac4f6a42ebd3adfb |  3.3.17 |   37 MB |      true |        12 |   15776619 |
| https://192.168.100.21:2379 | d241e2cf814e2ec1 |  3.3.17 |   37 MB |     false |        12 |   15776619 |
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
```
The current leader is https://192.168.100.23 (is leader true)
Let's move the leadership to https://192.168.100.21

We have to use for the leader the endpoint of the leader (https://192.168.100.23:2379) and for the new leader the hex ID of the member (d241e2cf814e2ec1)

```
sh-4.2# etcdctl --endpoints https://192.168.100.23:2379 move-leader d241e2cf814e2ec1
2020-04-05 14:56:06.371548 W | pkg/flags: recognized environment variable ETCDCTL_CERT, but unused: shadowed by corresponding flag
2020-04-05 14:56:06.371565 W | pkg/flags: recognized environment variable ETCDCTL_CACERT, but unused: shadowed by corresponding flag
2020-04-05 14:56:06.371570 W | pkg/flags: recognized environment variable ETCDCTL_KEY, but unused: shadowed by corresponding flag
Leadership transferred from ac4f6a42ebd3adfb to d241e2cf814e2ec1
```

Check the leadership again
```
sh-4.2# etcdctl endpoint status --cluster -w table
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
|          ENDPOINT           |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
| https://192.168.100.22:2379 | 570db60db6086170 |  3.3.17 |   37 MB |     false |        13 |   15776832 |
| https://192.168.100.23:2379 | ac4f6a42ebd3adfb |  3.3.17 |   37 MB |     false |        13 |   15776832 |
| https://192.168.100.21:2379 | d241e2cf814e2ec1 |  3.3.17 |   37 MB |      true |        13 |   15776832 |
+-----------------------------+------------------+---------+---------+-----------+-----------+------------+
```
The current leader is now https://192.168.100.21


## etcd encryption

#### Encrypt etcd

Modify the API server object and set the encryption field type to aescbc:

```
[root@services ~]# oc patch apiservers.config.openshift.io cluster --type=merge -p '{"spec": {"encryption": {"type": "aescbc"}}}'
```

Review the Encrypted status condition for the OpenShift API server to verify that its resources were successfully encrypted

```
[root@services ~]# oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
EncryptionCompleted
All resources encrypted: routes.route.openshift.io, oauthaccesstokens.oauth.openshift.io, oauthauthorizetokens.oauth.openshift.io
```

Review the Encrypted status condition for the Kubernetes API server to verify that its resources were successfully encrypted

```
[root@services ~]# oc get kubeapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
EncryptionCompleted
All resources encrypted: secrets, configmaps
```

#### Unencrypt etcd

Modify the API server object and set the encryption field type to identity:

```
[root@services ~]# oc patch apiservers.config.openshift.io cluster --type=merge -p '{"spec": {"encryption": {"type": "identity"}}}'
```

Review the Decrypted status condition for the OpenShift API server to verify that its resources were successfully decrypted

```
[root@services ~]# oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
DecryptionCompleted
Encryption mode set to identity and everything is decrypted
```

Review the Encrypted status condition for the Kubernetes API server to verify that its resources were successfully encrypted

```
[root@services ~]# oc get kubeapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
DecryptionCompleted
Encryption mode set to identity and everything is decrypted
```

## etcd backup


#### etcd backup the OpenShift way

SSH to any of the master host with a root/privileged user.
Run the etcd-snapshot-backup.sh by using the following command:
```
sudo /usr/local/bin/etcd-snapshot-backup.sh </path-to-directory>
```


