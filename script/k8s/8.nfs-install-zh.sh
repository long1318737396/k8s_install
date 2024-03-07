set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"



if [ -f /etc/debian_version ]; then
  systemctl enable nfs-kernel-server
  systemctl restart nfs-kernel-server

elif [ -f /etc/redhat-release ]; then
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
else
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
fi

mkdir -p ${nfs_path}
chmod -R 777 ${nfs_path}
echo "${nfs_path} *(rw,sync,no_root_squash,no_subtree_check)" | sudo tee -a /etc/exports
exportfs -ra
showmount -e localhost