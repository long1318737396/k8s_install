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


if [[ "$network_type" == "calico" ]]
    then
        kubectl apply -f ../../../yaml/calico.yaml 
    elif [[ "$network_type" == "cilium" ]]
        then
            cd ../../../yaml;
            helm upgrade --install cilium ./cilium --namespace=kube-system  --version 1.15.1 \
                --set routingMode=native \
                --set kubeProxyReplacement=strict \
                --set bandwidthManager.enabled=true \
                --set ipam.mode=kubernetes \
                --set k8sServiceHost=${loadbalancer_vip} \
                --set k8sServicePort=6443 \
                --set ipv4NativeRoutingCIDR=${pod_cidr} \
                --set operate.pprof=true \
                --set operate.prometheus.enabled=true \
                --set prometheus.enabled=true \
                --set pprof.enabled=true \
                --set nodePort.enabled=true \
                --set monitor.enabled=true \
                --set hubble.relay.enabled=true \
                --set hubble.relay.prometheus.enabled=true \
                --set hubble.relay.pprof.enabled=true \
                --set hubble.ui.enabled=true \
                --set hubble.ui.service.type=NodePort \
                --set hubble.metrics.enabled="{dns:query;ignoreAAAA,drop,tcp,flow,icmp,http}" \
                --set hubble.metrics.dashboards.enabled=true \
                --set ingressController.enabled=true \
                --set debug.enabled=false \
                --set operator.replicas=1 \
                --set bpf.masquerade=true \
                --set autoDirectNodeRoutes=true \
                --set gatewayAPI.enabled=true \
                --set ingressController.enabled=true \
                --set ingressController.service.type=NodePort \
                --set egressGateway.enabled=true 

    fi