## 查看etcd集群节点信息
```bash
ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  member list --write-out=table
```
## 查看集群状态
```bash
ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  endpoint status --write-out=table

ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  endpoint health --write-out=table
```

## 查看告警
```bash
ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  etcdctl alarm list

#删除所有告警
ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  etcdctl alarm disarm
```

## 添加成员
```bash
cat ~/.bashrc
HOST_1=https://192.168.10.100:2379
HOST_2=https://192.168.10.11:2379
HOST_3=https://192.168.10.12:2379
ENDPOINTS=${HOST_1},${HOST_2},${HOST_3}
# 如果需要使用原生命令，在命令开头加一个\ 例如：\etcdctl command
alias etcdctl="etcdctl --endpoints=${ENDPOINTS} --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"
alias etcdctljson="etcdctl --endpoints=${ENDPOINTS} --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --write-out=json"
alias etcdctltable="etcdctl --endpoints=${ENDPOINTS} --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --write-out=table"
source ~/.bashrc
```
- 查看集群节点信息

```bash
etcdctl endpoint status --cluster -w table
```
- 更新集群节点信息

```bash
etcdctl member update b112a60ec305e42a --peer-urls=http://192.168.10.100:22380
```
- 删除成员

```bash
etcdctl member remove b112a60ec305e42a
```
- 添加成员

```bash
etcdctl member add etcd3 https://10.4.7.11:2380
```

## 快照操作

- 生成快照

```bash
etcdctl snapshot save etcd-snapshot.db
```
- 查看快照

```bash
etcdctl snapshot status etcd-snapshot.db -w table
```
- 恢复快照

```bash
etcdctl snapshot restore snap.db --name=etcd2 --data-dir=/data/etcd/cluster.etcd --initial-cluster=etcd1=https://192.168.10.100:2380,etcd2=https://192.168.10.11:2380,etcd3=http://192.168.10.12:2380 --initial-advertise-peer-urls=https://192.168.10.11:2380
```

## 碎片整理

```bash
etcdctl defrag --cluster

```

## 案例: 磁盘满问题处理
```bash
ETCD_CA_CERT="/etc/kubernetes/pki/etcd/ca.crt"
ETCD_CERT="/etc/kubernetes/pki/etcd/server.crt"
ETCD_KEY="/etc/kubernetes/pki/etcd/server.key"
HOST_1=https://xxx.xxx.xxx.xxx:2379

ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" --write-out=table endpoint status

ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" alarm list

# 1.增加容量
--auto-compaction-mode=revision
--auto-compaction-retention=1000
--quota-backend-bytes=8589934592

auto-compaction-mode=revision 按版本号压缩
auto-compaction-retention=1000 保留近1000个revision，每5分钟自动压缩 "latest revision"
quota-backend-bytes 设置etcd最大容量为8G

重启etcd
# 2.压缩老数据
#获取当前etcd数据的修订版本
rev=$(ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \ --endpoints="${HOST_1}" endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')echo $rev

# 整合压缩旧版本数据
ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" compact $rev

# 碎片整理
ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" defrag

# 解除告警
ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" alarm disarm

# 添加数据
ETCDCTL_API=3 etcdctl --cacert="${ETCD_CA_CERT}" --cert="${ETCD_CERT}" --key="${ETCD_KEY}" \  --endpoints="${HOST_1}" put abc def
```
