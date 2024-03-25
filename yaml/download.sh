set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


helm repo add cilium https://helm.cilium.io/
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo add apollo https://charts.apolloconfig.com
helm repo add flannel https://flannel-io.github.io/flannel/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo add metallb https://metallb.github.io/metallb
helm repo add minio-operator https://operator.min.io
helm repo add openebs https://openebs.github.io/charts


wget https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
wget https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
#curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.3 TARGET_ARCH=${arch1} sh -
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
curl -fsSL https://addons.kuboard.cn/kuboard/kuboard-static-pod.sh -o kuboard.sh
git  clone https://github.com/prometheus-operator/kube-prometheus.git
wget https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml
wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml
wget https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
#git clone --single-branch --branch v1.13.5 https://github.com/rook/rook.git

helm repo update

helm pull cilium/cilium --version 1.15.1 --untar
helm pull projectcalico/tigera-operator --version v3.27.2 --untar
helm pull apollo/apollo-portal --untar
helm pull apollo/apollo-service --untar
helm pull flannel/flannel  --untar
helm pull prometheus-community/kube-prometheus-stack --version 15.1.0 --untar
helm pull nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --untar
helm pull grafana/loki-stack --untar
helm pull ingress-nginx/ingress-nginx --untar
helm pull metallb/metallb --untar
helm pull minio-operator/operator --untar
helm pull openebs/openebs --untar
helm pull oci://docker.io/envoyproxy/gateway-helm --version v1.0.0 --untar
#helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel
#helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.0.0 -n envoy-gateway-system --create-namespace