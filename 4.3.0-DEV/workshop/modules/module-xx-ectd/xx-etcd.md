# ETCD

### short history

### explore etcd

#### Get the member list

```
etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key -\
-cacert /etc/ssl/etcd/ca.crt -\
-endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
member list -w table
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
|        ID        | STATUS  |         NAME         |              PEER ADDRS              |        CLIENT ADDRS         |
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
| 570db60db6086170 | started | etcd-member-master02 | https://etcd-1.ocp4.h12.rhaw.io:2380 | https://192.168.100.22:2379 |
| ac4f6a42ebd3adfb | started | etcd-member-master03 | https://etcd-2.ocp4.h12.rhaw.io:2380 | https://192.168.100.23:2379 |
| d241e2cf814e2ec1 | started | etcd-member-master01 | https://etcd-0.ocp4.h12.rhaw.io:2380 | https://192.168.100.21:2379 |
+------------------+---------+----------------------+--------------------------------------+-----------------------------+
```

#### Endpoint status

```
etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
endpoint status -w table
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
|               ENDPOINT               |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
| https://etcd-0.ocp4.h12.rhaw.io:2379 | d241e2cf814e2ec1 |  3.3.17 |   69 MB |     false |         8 |     945547 |
| https://etcd-1.ocp4.h12.rhaw.io:2379 | 570db60db6086170 |  3.3.17 |   69 MB |      true |         8 |     945547 |
| https://etcd-2.ocp4.h12.rhaw.io:2379 | ac4f6a42ebd3adfb |  3.3.17 |   70 MB |     false |         8 |     945547 |
+--------------------------------------+------------------+---------+---------+-----------+-----------+------------+
```

#### Endpoint health

```
etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
endpoint health -w table
+--------------------------------------+--------+-------------+-------+
|               ENDPOINT               | HEALTH |    TOOK     | ERROR |
+--------------------------------------+--------+-------------+-------+
| https://etcd-2.ocp4.h12.rhaw.io:2379 |   true | 20.306241ms |       |
| https://etcd-0.ocp4.h12.rhaw.io:2379 |   true | 12.822589ms |       |
| https://etcd-1.ocp4.h12.rhaw.io:2379 |   true | 23.781412ms |       |
+--------------------------------------+--------+-------------+-------+
```

#### Get the current existing objects in the etcd database

```
# etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
get / --prefix --keys-only | sed '/^$/d' | cut -d/ -f3 | sort | uniq -c | sort -rn         
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

### compact etcd

An etcd cluster needs periodic maintenance to remain reliable. Depending on an etcd application's needs, this maintenance can usually be automated and performed without downtime or significantly degraded performance.
All etcd maintenance manages storage resources consumed by the etcd keyspace. Failure to adequately control the keyspace size is guarded by storage space quotas; if an etcd member runs low on space, a quota will trigger cluster-wide alarms which will put the system into a limited-operation maintenance mode. To avoid running out of space for writes to the keyspace, the etcd keyspace history must be compacted. Storage space itself may be reclaimed by defragmenting etcd members. Finally, periodic snapshot backups of etcd member state makes it possible to recover any unintended logical data loss or corruption caused by operational error.

Since etcd keeps an exact history of its keyspace, this history should be periodically compacted to avoid performance degradation and eventual storage space exhaustion. Compacting the keyspace history drops all information about keys superseded prior to a given keyspace revision. The space used by these keys then becomes available for additional writes to the keyspace.
The keyspace can be compacted automatically with `etcd`'s time windowed history retention policy, or manually with `etcdctl`. The `etcdctl` method provides fine-grained control over the compacting process whereas automatic compacting fits applications that only need key history for some length of time.

### defrag etcd

After compacting the keyspace, the backend database may exhibit internal fragmentation. Any internal fragmentation is space that is free to use by the backend but still consumes storage space. Compacting old revisions internally fragments `etcd` by leaving gaps in backend database. Fragmented space is available for use by `etcd` but unavailable to the host filesystem. In other words, deleting application data does not reclaim the space on disk.

The process of defragmentation releases this storage space back to the file system. Defragmentation is issued on a per-member so that cluster-wide latency spikes may be avoided.

To defragment an etcd member, use the `etcdctl defrag` command:

```sh
$ etcdctl defrag
Finished defragmenting etcd member[127.0.0.1:2379]
```

**Note that defragmentation to a live member blocks the system from reading and writing data while rebuilding its states**.

**Note that defragmentation request does not get replicated over cluster. That is, the request is only applied to the local node. Specify all members in `--endpoints` flag or `--cluster` flag to automatically find all cluster members.**

Run defragment operations for all endpoints in the cluster associated with the default endpoint:

```
# etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
defrag                  
Finished defragmenting etcd member[https://etcd-0.ocp4.h12.rhaw.io:2379]
Finished defragmenting etcd member[https://etcd-1.ocp4.h12.rhaw.io:2379]
Finished defragmenting etcd member[https://etcd-2.ocp4.h12.rhaw.io:2379]
```

### create etcd snapshots

Snapshotting the `etcd` cluster on a regular basis serves as a durable backup for an etcd keyspace. By taking periodic snapshots of an etcd member's backend database, an `etcd` cluster can be recovered to a point in time with a known good state.

A snapshot is taken with `etcdctl`:

```
# etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-2.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
snapshot save /var/lib/etcd/backup/etcd-$(date +%Y%m%d)/db
{"level":"warn","ts":"2020-02-13T14:22:29.278Z","caller":"clientv3/retry_interceptor.go:116","msg":"retry stream intercept"}
Snapshot saved at /var/lib/etcd/backup/etcd-20200213/db
```

### validate etcd snapshots

```
# etcdctl snapshot status /var/lib/etcd/backup/etcd-$(date +%Y%m%d)/db -w table
+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| 196aa56f |   768941 |       5989 |      70 MB |
+----------+----------+------------+------------+
```

### etcd performance check

```
etcdctl \
--cert /etc/ssl/etcd/system:etcd-server:etcd-0.ocp4.h12.rhaw.io.crt \
--key /etc/ssl/etcd/system:etcd-server:etcd-0.ocp4.h12.rhaw.io.key \
--cacert /etc/ssl/etcd/ca.crt \
--command-timeout=60s
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
check perf    
 60 / 60 Boooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00%1m0s
PASS: Throughput is 150 writes/s
PASS: Slowest request took 0.083526s
PASS: Stddev is 0.008879s
PASS
```
