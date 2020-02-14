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

### defrag etcd

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
--endpoints  https://etcd-0.ocp4.h12.rhaw.io:2379,https://etcd-1.ocp4.h12.rhaw.io:2379,https://etcd-2.ocp4.h12.rhaw.io:2379 \
check perf    
 60 / 60 Boooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo! 100.00%1m0s
PASS: Throughput is 150 writes/s
PASS: Slowest request took 0.083526s
PASS: Stddev is 0.008879s
PASS
```
