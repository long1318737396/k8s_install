
```bash
helm upgrade --install openebs --namespace openebs openebs/openebs --set cstor.enabled=true --create-namespace
```

```bash
#helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.0.0 -n envoy-gateway-system --create-namespace --set deployment.replicas=2

helm install eg ./gateway-helm --version v1.0.0 -n envoy-gateway-system --create-namespace --set deployment.replicas=1 \
  --set deployment.envoyGateway.imagePullPolicy=IfNotPresent \
  --set kubernetesClusterDomain=cluster.local
```


```bash
如果一些组件起不来，查看日志是由于连接不到10.96.0.10:443访问不通，可能是系统内核版本太低，或者是云服务环境下不支持native routing模式，可以将默认的网络转发模式改成走vxlan模式执行步骤如下:
#1.在master节点上先卸载cilium
helm uninstall -n kube-system cilium
#2.然后在master节点进行安装
cd k8s_install/yaml
按实际修改如下值
k8sServiceHost=192.168.0.47
ipv4NativeRoutingCIDR=10.244.0.0/16
helm upgrade --install cilium ./cilium --namespace=kube-system  --version 1.15.1 \
                --set routingMode=tunnel \
                --set kubeProxyReplacement=strict \
                --set bandwidthManager.enabled=true \
                --set ipam.mode=kubernetes \
                --set k8sServiceHost=192.168.0.47 \
                --set k8sServicePort=6443 \
                --set ipv4NativeRoutingCIDR=10.244.0.0/16 \
                --set operate.pprof=false \
                --set operate.prometheus.enabled=false \
                --set prometheus.enabled=false \
                --set pprof.enabled=false \
                --set nodePort.enabled=true \
                --set monitor.enabled=false \
                --set hubble.relay.enabled=false \
                --set hubble.relay.prometheus.enabled=false \
                --set hubble.relay.pprof.enabled=false \
                --set hubble.ui.enabled=false \
                --set hubble.ui.service.type=NodePort \
                --set hubble.metrics.enabled="" \
                --set hubble.metrics.dashboards.enabled=false \
                --set ingressController.enabled=false \
                --set debug.enabled=false \
                --set operator.replicas=1 \
                --set gatewayAPI.enabled=false \
                --set ingressController.enabled=true \
                --set ingressController.service.type=NodePort \
                --set egressGateway.enabled=false \
                --set l2announcements.enabled=true \
                --set k8sClientRateLimit.qps=100 \
                --set k8sClientRateLimit.burst=200

#3.重启coredns
kubectl rollout restart -n kube-system deployment coredns
```