source config.sh
mkdir -p "$kubeadm_dir"

tar -C $kubeadm_dir -xzf software/crictl-v${crictl_version}-linux-${arch}.tar.gz

#RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

/bin/cp  software/{kubeadm,kubelet,kubectl} $kubeadm_dir/
chmod +x $kubeadm_dir/{kubeadm,kubelet,kubectl}

cat conf/kubelet.service | sed "s:/usr/bin:${kubeadm_dir}:g" |tee /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cat conf/10-kubeadm.conf | sed "s:/usr/bin:${kubeadm_dir}:g" | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl enable --now kubelet
echo "source <(kubectl completion bash)" > /etc/profile.d/kubectl.sh
echo "source <(kubeadm completion bash)" > /etc/profile.d/kubeadm.sh

cd images/
tar -zxvf base-image.tar.gz
cd ../
for i in `ls images/base-image`;do nerdctl load -i images/base-image/$i;done
mkdir -p /etc/kubernetes/manifests/
/bin/cp yaml/kube-vip.yaml /etc/kubernetes/manifests/kube-vip.yaml
