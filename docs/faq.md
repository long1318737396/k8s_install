## 1.使用外部负载均衡注意事项

1、外部负载均衡建议需采用四层模式，apiserver默认是开启自签名tls的

2、外部负载均衡需要支持回模式，如果不支持建议采用kube-vip + 虚拟IP形式

## 2.cilium使用vxaln部署

如果遇到pod访问apiserver联通不上问题，可以使用[vxlan](../script/k8s/README.md)模式部署


之后重启cilium

kubectl rollout restart ds -n kube-system cilium

kubectl rollout restart deployment -n kube-system cilium-operator

## 3.prometheus采集外部主机

相应IP和端口替换成真实IP和端口
```yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mysql-node-exporter01
  name: mysql-node-exporter01
  namespace: environment
spec:
  type: ClusterIP
  ports:
  - name: metrics
    port: 9100
    protocol: TCP
    targetPort: 9100  #监控主机端口
---
apiVersion: v1
kind: Endpoints
metadata:
  labels:
    app: mysql-node-exporter01
  name: mysql-node-exporter01
  namespace: environment
subsets:
- addresses:
  - ip: 10.212.16.138  #监控主机IP
  ports:
  - name: metrics
    port: 9100
    protocol: TCP
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: mysql-node-exporter01
    prometheus: k8s
  name: mysql-node-exporter01
  namespace: environment
spec:
  endpoints:
    - interval: 1m
      port: metrics
  namespaceSelector:
    matchNames:
      - environment
  selector:
    matchLabels:
      app: mysql-node-exporter01
```
之后确认endpoints是否正常

kubectl get endpoints -n environment mysql-node-exporter01

如果显示地址为10.212.16.138则代表正常

## 4.metallb实现软负载

配置地址池
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.10.0/24
  - 192.168.9.1-192.168.9.5
  - fc00:f853:0ccd:e799::/124
```
配置地址池通告

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```
使用地址池
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    metallb.universe.tf/address-pool: production-public-ips
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
```

## openebs做为高可用存储

[openebs](openebs.md)


## ebpf解决后端服务获取源IP问题

借助网络插件calico的ebpf功能

```bash
kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: kube-system
data:
  KUBERNETES_SERVICE_HOST: '<API server host>'
  KUBERNETES_SERVICE_PORT: '<API server port>'
kubectl delete pod -n kube-system -l k8s-app=calico-node
kubectl delete pod -n kube-system -l k8s-app=calico-kube-controllers
kubectl patch ds -n kube-system kube-proxy -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": "true"}}}}}'
#kubectl patch felixconfiguration default --patch='{"spec": {"bpfKubeProxyIptablesCleanupEnabled": false}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfEnabled": true}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfExternalServiceMode": "DSR"}}'
calicoctl patch felixconfiguration default --patch='{"spec": {"bpfExternalServiceMode": "Tunnel"}}'
```

## 基于istio的灰度发布

https://www.yuque.com/tiancaiyihao/ormg6p/csubkbg4z1l80fbb?singleDoc# 《基于istio进行灰度发布》


## 实现容器间共享内存

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shared-memory-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shared-memory-pod
  template:
    metadata:
      labels:
        app: shared-memory-pod
    spec:
      volumes:
        - name: dshm
          emptyDir:
            medium: Memory
            sizeLimit: "1Gi"
      containers:
        - name: net-tools
          image: long1318737396/net-tools
          volumeMounts:
            - name: dshm
              mountPath: /dev/shm
```

## pod磁盘限制

以下配置当pod磁盘使用超过1G时，就会被kill，然后新起pod
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: my-image
        volumeMounts:
          - name: my-empty-dir
            mountPath: /mnt/data
        resources:
          limits:
            ephemeral-storage: 1Gi
      volumes:
      - name: my-empty-dir
        emptyDir:
          sizeLimit: 1Gi
```

## ecapture抓https数据包
```bash
wget https://github.com/gojue/ecapture/releases/download/v0.7.3/ecapture-v0.7.3-linux-x86_64.tar.gz
tar -zxvf ecapture-v0.7.3-linux-x86_64.tar.gz
cp ecapture-v0.7.3-linux-x86_64/ecapture /usr/local/bin/

ecapture tls -m pcap -i eth0 --pcapfile=ecapture.pcapng --port=6443 and --port 10250
```

## calico的BGP配置示例

[calico BGP](clalico_bgp.md)

## yum离线包制作

[centos8 yum离线包制作](../offline/yum/amd64/README.md)


## kubelet metrics获取

```bash
echo "
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: default
  name: cls-access
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cls-access
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    namespace: default
    name: cls-access
" | kubectl  apply -f - 

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cls-access
  annotations:
    kubernetes.io/service-account.name: "cls-access"
type: kubernetes.io/service-account-token
EOF

kubectl get secrets cls-access -o yaml
TOKEN=$(kubectl get secret cls-access -o jsonpath='{.data.token}'|base64 -d)
```

```请求测试
curl --header "Authorization: Bearer $TOKEN" --insecure  -X GET https://10.0.0.105:10250/metrics
curl --header "Authorization: Bearer $TOKEN" --insecure  -X GET https://10.0.0.105:10250/metrics/cadvisor
```

## calico 固定pod的IP地址

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1 # tells deployment to run 1 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
      annotations:
        "cni.projectcalico.org/ipAddrs": "[\"10.244.1.135\"]"
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

## 对于nfs只能挂载node节点时的storageclass配置

本脚本集成了对rancher local-path的sc，当遇到nfs只能挂到node宿主机目录时，可以修改local-path的cm变成nfs的映射地址，然后进行动态存储卷的挂载

```bash
kubectl edit cm -n local-path-storage local-path-config


修改对应的paths路径为nfs映射宿主机的地址，这个时候安装loki以及prometheus需要将sc的名称改成nfs-client改成local-path

 "nodePathMap":[
            {
                    "node":"DEFAULT_PATH_FOR_NON_LISTED_NODES",
                    "paths":["/images/k8s"]
            }
            ]


```
然后重启local-path-controller
```bash
kubectl delete pod -n local-path-storage -l app=local-path-provisioner
```

## helm部署应用报错

Error: UPGRADE FAILED: another operation (install/upgrade/rollback) is in progress

主要是最近的一次部署结果是pending-upgrade 所以阻塞了我们的继续部署
```bash
helm  history  -n environment prometheus
执行如下命令回退即可
helm rollback -n environment prometheus 1 
回退之后发现有pod启动报错，可以先卸载然后进行排查再安装
```
## grafana重启之后报错

logger=provisioning t=2024-03-12T02:58:51.000830244Z level=error msg="Failed to provision data sources" error="Datasource provisioning error: datasource.yaml config is invalid. Only one datasource per organization can be marked as default"
logger=provisioning t=2024-03-12T02:58:51.000854373Z level=error msg="Failed to provision data sources" error="Datasource provisioning error: datasource.yaml config is invalid. Only one datasource per organization can be marked as default"
Error: ✗ Datasource provisioning error: datasource.yaml config is invalid. Only one datasource per organization can be marked as default

```bash
解决办法
kubectl edit cm -n environment prometheus-kube-prometheus-grafana-datasource
将下面的配置修改为
orgID: 2
然后重启grafana pod
```
## ingress的灰度发布和蓝绿发布

https://help.aliyun.com/zh/ack/ack-managed-and-ack-dedicated/user-guide/use-the-nginx-ingress-controller-for-canary-releases-and-blue-green-deployments-1?spm=a2c4g.11186623.0.0.6220a14eCXghvj

## kuboard单独部署

kuboard 通过docker单独部署
```bash
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 80:80/tcp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://内网IP:80" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:v3.5.2.6
  # 也可以使用镜像 swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3 ，可以更快地完成镜像下载。
  # 请不要使用 127.0.0.1 或者 localhost 作为内网 IP \
  # Kuboard 不需要和 K8S 在同一个网段，Kuboard Agent 甚至可以通过代理访问 Kuboard Server \

```