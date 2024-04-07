```bash
cilium的vxlan模式
# 卸载以安装的cilium

helm uninstall cilium -n kube-system


cd yaml

#修改apiserver地址和pod对应的地址段
helm upgrade --install cilium ./cilium --namespace=kube-system  --version 1.15.1 \
  --set tunnelProtocol=vxlan \
  --set routingMode=tunnel \
  --set kubeProxyReplacement=strict \
  --set bandwidthManager.enabled=true \
  --set bandwidthManager.bbr=true \
  --set ipam.mode=kubernetes \
  --set k8sServiceHost=172.16.10.203 \
  --set k8sServicePort=6443 \
  --set ipv4NativeRoutingCIDR=10.244.0.0/16 \
  --set operator.pprof.enabled=true \
  --set operator.replicas=1 \
  --set operator.prometheus.enabled=true \
  --set operator.dashboards.enabled=true \
  --set prometheus.enabled=true \
  --set dashboards.enabled=true \
  --set envoy.enabled=true \
  --set pprof.enabled=true \
  --set monitor.enabled=true \
  #--set loadBalancer.mode=dsr \
  --set loadBalancer.l7.backend=envoy \
  --set nodePort.enabled=true \
  --set socketLB.enabled=true \
  --set gatewayAPI.enabled=true \
  --set envoyConfig.enabled=true \
  --set bgpControlPlane.enabled=true \
  --set bgp.enabled=false \
  --set monitor.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.relay.prometheus.enabled=true \
  --set hubble.relay.pprof.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.ui.frontend.service.type=NodePort \
  --set hubble.metrics.enabled="{dns:query;ignoreAAAA,drop,tcp,flow,icmp,http}" \
  --set ingressController.enabled=true \
  --set ingressController.service.type=NodePort \
  --set egressGateway.enabled=true \
  --set enableIPv4BIGTCP=false \
  --set ipMasqAgent.enabled=true \
  --set debug.enabled=true \
  --set preflight.enabled=false \
  --set externalWorkloads.enabled=true \
  --set sctp.enabled=true \
  --set bpf.masquerade=true \
  --set pmtuDiscovery.enabled=true
```