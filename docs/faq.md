## 1.使用外部负载均衡注意事项

1、外部负载均衡建议需采用四层模式，apiserver默认是开启自签名tls的

2、外部负载均衡需要支持回模式，如果不支持建议采用kube-vip + 虚拟IP形式

## 2.cilium使用vxaln部署

如果遇到pod访问apiserver联通不上问题，可以使用vxlan模式部署
[vxlan](../script/k8s/README.md)

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