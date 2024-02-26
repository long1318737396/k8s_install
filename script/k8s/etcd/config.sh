set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

etcd_ssldir=/etc/kubernetes/etcd
etcd_datadir="${etcd_data_dir}"
etcd_software=
etcd1_ip=172.16.10.203
etcd2_ip=172.16.10.204
etcd3_ip=172.16.10.205
ETCD_VER=v3.5.12