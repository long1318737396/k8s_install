set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/bin/${arch}


tar -zxvf velero-${velero_version}-linux-${arch}.tar.gz
/bin/cp velero-${velero_version}-linux-${arch}/velero /usr/local/bin/
chmod +x /usr/local/bin/velero
velero completion bash > /etc/bash_completion.d/velero

/bin/cp skopeo-linux-${arch} /usr/local/bin/skopeo

chmod +x /usr/local/bin/skopeo

/bin/cp jq-linux-${arch} /usr/local/bin/jq
/bin/cp cfssl_${cfssl_version}_linux_${arch} /usr/local/bin/cfssl
/bin/cp cfssl-certinfo_${cfssl_version}_linux_${arch} /usr/local/bin/cfssl-certinfo
/bin/cp cfssljson_${cfssl_version}_linux_${arch} /usr/local/bin/cfssljson
/bin/cp minio /usr/local/bin/
/bin/cp mc /usr/local/bin/

chmod +x /usr/local/bin/{jq,cfssl,cfssl-certinfo,cfssljson,minio,mc}


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



tar -C $kubeadm_dir -xzf crictl-${crictl_version}-linux-${arch}.tar.gz

#RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

tar -zxvf kubernetes-server-linux-${arch}.tar.gz
/bin/cp kubernetes/server/bin/{kubelet,kubectl} $kubeadm_dir/
/bin/cp  kubeadm $kubeadm_dir/
chmod +x $kubeadm_dir/{kubeadm,kubelet,kubectl}

cat ../../../conf/kubelet.service | sed "s:/usr/bin:${kubeadm_dir}:g" |tee /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cat ../../../conf/10-kubeadm.conf | sed "s:/usr/bin:${kubeadm_dir}:g" | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

mkdir -p /etc/kubernetes/audit-policy/
cat ../../../conf/audit-policy.yaml | tee /etc/kubernetes/audit-policy/audit-policy.yaml

mkdir -p /var/log/audit

systemctl enable --now kubelet
echo "source <(kubectl completion bash)" > /etc/profile.d/kubectl.sh
echo "source <(kubeadm completion bash)" > /etc/profile.d/kubeadm.sh