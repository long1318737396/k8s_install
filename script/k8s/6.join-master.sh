set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cat ../../conf/kubeadm-control-plane-join.yaml | sed "s:\${loadbalancer_vip}:${loadbalancer_vip}:g" |tee kubeadm-control-plane-join.yaml

kubeadm init --config kubeadm-control-plane-join.yaml --v 5