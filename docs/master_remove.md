## 移除master节点

```bash
kubectl drain <master-node-name> --ignore-daemonsets --delete-emptydir-data --force
kubectl delete node <master-node-name>
```

移除etcd

```bash
由于etcd是堆叠部署的
如果旧的master移除，etcd不需要，则需要进行移除
alias etcdctl="ETCDCTL_API=3 /usr/local/bin/etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"


etcdctl member list #获取成员ID
etcdctl member remove ${memberID}
etcdctl endpoint status --cluster --write-out=table #检查
etcdctl endpoint health --cluster --write-out=table #确保当前集群正常
```