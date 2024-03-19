set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/bin/${arch}
tar -zxvf helm-v${helm_version}-linux-${arch}.tar.gz
cp linux-${arch}/helm /usr/local/bin/
chmod +x /usr/local/bin/helm 
helm completion bash > /etc/profile.d/helm.sh
tar -zxvf etcd-${etcd_version}-linux-${arch}.tar.gz
/bin/cp etcd-${etcd_version}-linux-${arch}/{etcdutl,etcdctl} /usr/local/bin/
chmod +x /usr/local/bin/{etcdutl,etcdctl}
/bin/cp calicoctl-linux-${arch} /usr/local/bin/calicoctl

tar -zxvf hubble-linux-${arch}.tar.gz 
/bin/cp hubble /usr/local/bin/
chmod +x /usr/local/bin/hubble

tar -zxvf cilium-linux-${arch}.tar.gz
/bin/cp cilium /usr/local/bin/
chmod +x /usr/local/bin/cilium
cilium completion bash > /etc/bash_completion.d/cilium

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