set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/bin/${arch}

tar -C $kubeadm_dir -xzf crictl-${crictl_version}-linux-${arch}.tar.gz

#RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

tar -zxvf kubernetes-server-linux-${arch}.tar.gz
/bin/cp kubernetes/server/bin/{kubelet,kubeadm} $kubeadm_dir/
/bin/cp  kubeadm $kubeadm_dir/
chmod +x $kubeadm_dir/{kubeadm,kubelet,kubectl}

cat ../../../conf/kubelet.service | sed "s:/usr/bin:${kubeadm_dir}:g" |tee /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cat ../../../conf/10-kubeadm.conf | sed "s:/usr/bin:${kubeadm_dir}:g" | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable --now kubelet
echo "source <(kubectl completion bash)" > /etc/profile.d/kubectl.sh
echo "source <(kubeadm completion bash)" > /etc/profile.d/kubeadm.sh


mkdir -p /etc/kubernetes/manifests/

if [[ "$kube_vip_enable" == "true" ]]
then
    cat ../../../yaml/first-master-kube-vip.yaml \
        | sed -e "s/\${kube_vip}/${kube_vip}/g" \
              -e "s/\{kube_vip_eth}/${kube_vip_eth}/g" \
        | tee /etc/kubernetes/manifests/kube-vip.yaml
fi
