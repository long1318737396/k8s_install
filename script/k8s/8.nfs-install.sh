set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


mkdir -p ${nfs_path}
chmod -R 777 ${nfs_path}
echo "${nfs_path} *(rw,sync,no_root_squash,no_all_squash)" | sudo tee -a /etc/exports
exportfs -ra
systemctl enable nfs-server
systemctl start nfs-server