## 如果没有vip可以参考此配置

- 编辑配置文件确保kube_vip_enable=false,loadbalancer_vip配置为master1节点的IP地址

```bash
vi conf/config.sh
kube_vip_enable=false
loadbalancer_vip=192.168.1.117
```

- 按照正常流程安装k8s集群

- master2节点的做如下配置修改

将里面的server地址改成127.0.0.1
```bash
for i in `ls /etc/kubernetes|grep .conf`;do echo "$i";cat /etc/kubernetes/$i|grep server;done
for i in `ls /etc/kubernetes|grep .conf`;do sed -i -e 's/10.64.4.168/127.0.0.1/g' -e 's/10.64.4.170/127.0.0.1/g' /etc/kubernetes/$i;done
```
重启kubelet
```bash
systemctl daemon-reload
systemctl restart kubelet
```

- master3节点的做如下配置修改

将里面的server地址改成127.0.0.1
```bash
for i in `ls /etc/kubernetes|grep .conf`;do echo "$i";cat /etc/kubernetes/$i|grep server;done
for i in `ls /etc/kubernetes|grep .conf`;do sed -i -e 's/10.64.4.168/127.0.0.1/g' -e 's/10.64.4.170/127.0.0.1/g' /etc/kubernetes/$i;done
```

- 每台node节点配置

安装前添加nginx代理或者haproxy代理
```bash
mkdir /etc/kubernetes/manifests
vi /etc/kubernetes/manifests/haproxy.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: haproxy
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: kube-haproxy
  annotations:
    haproxy-cfg-checksum: "105b41ada1064ba25274f482d6100b8b29f1dfc8"
spec:
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
  nodeSelector:
    kubernetes.io/os: linux
  priorityClassName: system-node-critical
  containers:
  - name: haproxy
    image: docker.io/library/haproxy:2.8.2-alpine
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 25m
        memory: 32M
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8081
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8081
    volumeMounts:
    - mountPath: /usr/local/etc/haproxy/
      name: etc-haproxy
      readOnly: true
  volumes:
  - name: etc-haproxy
    hostPath:
      path: /etc/haproxy
```
```bash
vi /etc/haproxy/haproxy.cfg
```
将以下的server里面的地址改成对应的master IP地址
```conf
global
    maxconn                 4000
    log                     127.0.0.1 local0

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option                  http-server-close
    option                  redispatch
    retries                 5
    timeout http-request    5m
    timeout queue           5m
    timeout connect         30s
    timeout client          5m
    timeout server          15m
    timeout http-keep-alive 30s
    timeout check           30s
    maxconn                 4000

frontend healthz
  bind 0.0.0.0:8081
  mode http
  monitor-uri /healthz

frontend kube_api_frontend
  bind 127.0.0.1:6443
  mode tcp
  option tcplog
  default_backend kube_api_backend

backend kube_api_backend
  mode tcp
  balance leastconn
  default-server inter 15s downinter 15s rise 2 fall 2 slowstart 60s maxconn 1000 maxqueue 256 weight 100
  option httpchk GET /healthz
  http-check expect status 200
  server node1 10.64.4.168:6443 check check-ssl verify none
  server node2 10.64.4.169:6443 check check-ssl verify none
  server node3 10.64.4.170:6443 check check-ssl verify none
```
集群安装完之后，将里面的server地址改成127.0.0.1
```bash
for i in `ls /etc/kubernetes|grep .conf`;do echo "$i";cat /etc/kubernetes/$i|grep server;done
for i in `ls /etc/kubernetes|grep .conf`;do sed -i -e 's/10.64.4.168/127.0.0.1/g' -e 's/10.64.4.170/127.0.0.1/g' /etc/kubernetes/$i;done
```
