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

/bin/cp jq-linux-${arch} /usr/local/bin/jq
chmod +x /usr/local/bin/jq

cat ../../conf/kubeadm-control-plane-join.yaml | sed "s:\${loadbalancer_vip}:${loadbalancer_vip}:g" |tee kubeadm-control-plane-join.yaml


mkdir -p /etc/kubernetes/manifests/

if [[ "$kube_vip_enable" == "true" ]]
then
    cat ../../yaml/other-master-kube-vip.yaml \
        | sed -e "s/\${loadbalancer_vip}/${loadbalancer_vip}/g" \
              -e "s/\${kube_vip_eth}/${kube_vip_eth}/g" \
        | tee /etc/kubernetes/manifests/kube-vip.yaml
fi

kubeadm join --config kubeadm-control-plane-join.yaml --v 5

mkdir -p $HOME/.kube
sudo /bin/cp  /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config