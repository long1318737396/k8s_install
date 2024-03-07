set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

echo "$harbor_ip $harbor_hostname" >> /etc/hosts
bash script/k8s/2.kubeadm-install.sh
if [ $? -ne 0 ]; then
  echo "k8s安装失败，请查看相关日志解决，然后执行kubeadm reset --force重置重新安装"
  exit 1
fi
bash script/k8s/7.join-node.sh