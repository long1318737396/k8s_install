set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

bash script/k8s/2.kubeadm-install.sh
bash script/k8s/3.k8s-install.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
bash script/k8s/4.net-work.sh
