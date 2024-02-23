set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

envsubst < ../../conf/kubeadm.yaml > kubeadm-config.yaml
kubeadm init --config=kubeadm-config.yaml --upload-certs
