## 等k8s集群初始化完成之后进行组件的安装,这样可以保证组件运行在各个节点上

- 登录任一台master节点

确认集群处于正常状态
```bash
kubectl get node -owide
kubectl get cs
```
安装addon组件
默认会安装以下组件，可以根据需求进行增删改,脚本文件位于 vi script/k8s/5.addon.sh

|           |                       |
|     ---   |         ---           |
|      组件名称     |   安装方式        |
| metrics-server    |    yaml           |
| gateway api   crd    |    yaml           |
| metallb-native    |    yaml           |
|    ingress-nginx  |    helm           |
| reloader          |    yaml         |
|  redis            |    yaml   |
| local-path-storage |  yaml   |
| kuboard   |    yaml          |
|   nfs-subdir-external-provisioner  |    helm           |
|  kube-prometheus-stack     |    helm   |
|  loki         | helm  |
| apollo        |   helm    |
| net-tools     |      yaml  |
| chat2db       |   yaml   |

组件安装
```bash
bash 9.addon_install.sh
```

**可选** 允许ingress-nginx-controller容忍调度到master节点上

ingress-nginx使用hostwork模式,访问ingress可以通过任意node节点IP+80端口

如果需要运行在master节点上，需要修改ingress-nginx-controller的tolerations，这样就可以通过master节点的IP+80端口访问了

```bash
kubectl patch daemonset -n environment ingress-nginx-controller --type json -p '[{"op": "add", "path": "/spec/template/spec/tolerations", "value": [{"key": "node-role.kubernetes.io/control-plane", "effect": "NoSchedule"}]}]'
```

如果需要修改默认的80端口，需要修改ingress-nginx-controller的启动端口

```bash
kubectl edit ds -n environment ingress-nginx-controller
#修改容器的启动参数,例如:
- --http-port=8081
```


**确认组件安装正常**

确认除apollo之外，其他pod都处于Runnging状态

```bash
kubectl get pod -A -owide
```