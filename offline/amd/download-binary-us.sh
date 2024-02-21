dir="$(cd "$(dirname "$0")" && pwd)"
source "../${dir}/conf/config.sh"
arch=amd64
arch1="x86_64"
save_dir="/data/kubernetes/packages/amd"
mkdir -p ${save_dir}
cd ${save_dir}
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"
# https://github.com/containernetworking/plugins/releases/
# https://github.com/containerd/containerd/releases/
# https://github.com/containerd/nerdctl/releases
# https://github.com/kubernetes-sigs/cri-tools/releases/
# https://github.com/Mirantis/cri-dockerd/releases/
# https://github.com/etcd-io/etcd/releases/
# https://github.com/cloudflare/cfssl/releases/
# https://github.com/kubernetes/kubernetes/tree/master/CHANGELOG
# https://download.docker.com/linux/static/stable/x86_64/
# https://github.com/opencontainers/runc/releases/
# https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/x86_64/RPMS/
# https://github.com/helm/helm/tags
# http://nginx.org/download/
# https://github.com/cri-o/cri-o/releases
# https://github.com/goharbor/harbor/releases
# https://github.com/docker/compose/releases/
kernel_version='5.4.260'
runc_version='1.1.12'
docker_version='25.0.3'
cni_plugins_version='v1.4.0'
containerd_version='1.7.13'
nerdctl_full_version='1.7.4'
crictl_version='v1.29.0'
cri_dockerd_version='0.3.10'
etcd_version='v3.5.12'
cfssl_version='1.6.4'
helm_version='3.14.1'
kubernetes_server_version='1.29.2'
nginx_version='1.25.3'
cri_o_version='V1.29.1'
docker_compose_version='v2.24.6'
harbor_version='v2.9.2'
calicoctl_version=3.27.2
cilium_version=v0.15.23
hubble_version=v0.13.0

base_url='https://mirrors.chenby.cn/'
kernel_url="http://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el7/$arch1/RPMS/kernel-lt-${kernel_version}-1.el7.elrepo.$arch1.rpm"
runc_url="https://github.com/opencontainers/runc/releases/download/v${runc_version}/runc.$arch"
docker_url="https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/$arch1/docker-${docker_version}.tgz"
cni_plugins_url="https://github.com/containernetworking/plugins/releases/download/${cni_plugins_version}/cni-plugins-linux-$arch-${cni_plugins_version}.tgz"
containerd_url="https://github.com/containerd/containerd/releases/download/v${cri_containerd_cni_version}/cri-containerd-cni-${cri_containerd_cni_version}-linux-$arch.tar.gz"
nerdctl_full_url="https://github.com/containerd/nerdctl/releases/download/v${nerdctl_full_version}/nerdctl-full-${nerdctl_full_version}-linux-$arch.tar.gz"
crictl_url="https://github.com/kubernetes-sigs/cri-tools/releases/download/${crictl_version}/crictl-${crictl_version}-linux-$arch.tar.gz"
cri_dockerd_url="https://github.com/Mirantis/cri-dockerd/releases/download/v${cri_dockerd_version}/cri-dockerd-${cri_dockerd_version}.$arch.tgz"
etcd_url="https://github.com/etcd-io/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-$arch.tar.gz"
cfssl_url="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl_${cfssl_version}_linux_$arch"
cfssljson_url="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssljson_${cfssl_version}_linux_$arch"
cfssl_certinfo="https://github.com/cloudflare/cfssl/releases/download/v${cfssl_version}/cfssl-certinfo_${cfssl_version}_linux_$arch"
helm_url="https://get.helm.sh/helm-v${helm_version}-linux-$arch.tar.gz"
kubernetes_server_url="https://storage.googleapis.com/kubernetes-release/release/v${kubernetes_server_version}/kubernetes-server-linux-$arch.tar.gz"
nginx_url="http://nginx.org/download/nginx-${nginx_version}.tar.gz"
cri_o_url="https://storage.googleapis.com/cri-o/artifacts/cri-o.$arch.${cri_o_version}.tar.gz"
harbor_url="https://github.com/goharbor/harbor/releases/download/${harbor_version}/harbor-offline-installer-${harbor_version}.tgz"
docker_compose_url=https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-linux-$arch1
calicoctl_url=https://github.com/projectcalico/calico/releases/download/v${calicoctl_version}/calicoctl-linux-$arch
cilium_url=https://github.com/cilium/cilium-cli/releases/download/${cilium_version}/cilium-linux-$arch.tar.gz
hubble_url=https://github.com/cilium/hubble/releases/download/$hubble_version/hubble-linux-$arch.tar.gz


https://github.com/goharbor/harbor/releases/download/v2.9.2/harbor-offline-installer-v2.9.2.tgz
packages=(
  #$kernel_url
  #$runc_url
  $docker_url
  #$cni_plugins_url
  #$containerd_url
  ${nerdctl_full_url}
  $crictl_url
  #$cri_dockerd_url
  $etcd_url
  $cfssl_url
  $cfssljson_url
  $cfssl_certinfo
  $helm_url
  $kubernetes_server_url
  #$nginx_url
  #${cri_o_url}
  $harbor_url
  $docker_compose_url
  $calicoctl_url
  $cilium_url
  $hubble_url
)

for package_url in "${packages[@]}"; do
  filename=$(basename "$package_url")
  if curl  -k -L -C - -o "$filename" "$package_url"; then
    echo "Downloaded $filename"
  else
    echo "Failed to download $filename"
    exit 1
  fi
done

chmod +x docker-compose-linux-$arch1
chmod +x calicoctl-linux-$arch
chmod +x cfssl_${cfssl_version}_linux_$arch
chmod +x cfssljson_${cfssl_version}_linux_$arch
chmod +x cfssl-certinfo_${cfssl_version}_linux_$arch