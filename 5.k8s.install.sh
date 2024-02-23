set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

bash script/k8s/2.kubeadm-install.sh
bash script/k8s/3.k8s-install.sh
bash script/k8s/4.net-work.sh
bash script/k8s/5.addon.sh