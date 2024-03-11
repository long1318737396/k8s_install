## 使用外部负载均衡注意事项

1、外部负载均衡建议需采用四层模式，apiserver默认是开启自签名tls的

2、外部负载均衡需要支持回模式，如果不支持建议采用kube-vip + 虚拟IP形式

## cilium使用vxaln部署

如果遇到pod访问apiserver联通不上问题，可以使用vxlan模式部署
[vxlan](../script/k8s/README.md)

之后重启cilium
kubectl rollout restart ds -n kube-system cilium
kubectl rollout restart deployment -n kube-system cilium-operator

## prometheus采集外部主机

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
    targetPort: 9100
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
  - ip: 10.212.16.138
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

## 告警配置


