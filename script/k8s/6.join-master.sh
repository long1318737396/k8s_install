set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

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