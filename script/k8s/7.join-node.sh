set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cat ../../conf/kubeadm-join-node.yaml | sed "s:\${loadbalancer_vip}:${loadbalancer_vip}:g" |tee kubeadm-join-node.yaml

kubeadm join --config kubeadm-join-node.yaml --v 5