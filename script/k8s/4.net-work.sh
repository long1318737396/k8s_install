set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/bin/${arch}


if [[ "$network_type" == "calico" ]]
    then
        kubectl apply -f ../../../yaml/calico.yaml 
    elif [[ "$network_type" == "cilium" ]]
        then
            cd ../../../yaml;
            # gateway api安装
            kubectl apply -f experimental-install.yaml;
            helm upgrade --install cilium ./cilium --namespace=kube-system  --version 1.15.1 \
                --set routingMode=native \
                --set kubeProxyReplacement=strict \
                --set bandwidthManager.enabled=true \
                --set ipam.mode=kubernetes \
                --set k8sServiceHost=${loadbalancer_vip} \
                --set k8sServicePort=6443 \
                --set ipv4NativeRoutingCIDR=${pod_cidr} \
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
                --set ingressController.enabled=true \
                --set debug.enabled=false \
                --set operator.replicas=1 \
                --set bpf.masquerade=true \
                --set autoDirectNodeRoutes=true \
                --set gatewayAPI.enabled=false \
                --set ingressController.enabled=true \
                --set ingressController.service.type=NodePort \
                --set egressGateway.enabled=false \
                --set l2announcements.enabled=true \
                --set k8sClientRateLimit.qps=100 \
                --set k8sClientRateLimit.burst=200 
    fi