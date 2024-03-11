## 部署需求

节点上需要插入裸盘

每个节点上需要安装iscsi-initiator-utils
```bash
yum install iscsi-initiator-utils -y
sudo systemctl enable --now iscsid
```

安装operator

```bash
kubectl apply -f https://openebs.github.io/charts/cstor-operator.yaml
```

确认磁盘是否被正确识别
```bash
kubectl get bd -n openebs
```

加入存储池
```yaml
apiVersion: cstor.openebs.io/v1
kind: CStorPoolCluster
metadata:
  name: cstor-storage
  namespace: openebs
spec:
  pools:
    - nodeSelector:
        kubernetes.io/hostname: "master"
      dataRaidGroups:
        - blockDevices:
            - blockDeviceName: "blockdevice-abdd08ab91ce9defa26f844e78f3f494"
      poolConfig:
        dataRaidGroupType: "stripe"

    - nodeSelector:
        kubernetes.io/hostname: "node1" 
      dataRaidGroups:
        - blockDevices:
            - blockDeviceName: "blockdevice-bc64f32c53a6cfc19c6d9bad7a4688a2"
      poolConfig:
        dataRaidGroupType: "stripe"
   
    - nodeSelector:
        kubernetes.io/hostname: "node2"
      dataRaidGroups:
        - blockDevices:
            - blockDeviceName: "blockdevice-9bee2abb83170847aa8c0684a7051554"
      poolConfig:
        dataRaidGroupType: "stripe"
```

创建storageclass
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: cstor-csi
provisioner: cstor.csi.openebs.io
allowVolumeExpansion: true
parameters:
  cas-type: cstor
  # cstorPoolCluster should have the name of the CSPC
  cstorPoolCluster: cstor-storage
  # replicaCount should be <= no. of CSPI
  replicaCount: "3"
```

创建pvc进行测试
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: demo-cstor-vol
spec:
  storageClassName: cstor-csi
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```