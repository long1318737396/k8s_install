set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


minio_datadir=/minio
/bin/cp ../../conf/minio.service /etc/systemd/system/minio.service

mkdir /etc/default
/bin/cp ../../conf/minio.config /etc/default/minio

sed -i "s/minio_datadir/${minio_datadir}/g" /etc/default/minio

groupadd -r minio-user
useradd -M -r -g minio-user minio-user
chown minio-user:minio-user ${minio_datadir}

systemctl start minio.service --enable