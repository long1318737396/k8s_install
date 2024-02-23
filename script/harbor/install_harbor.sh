set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cp ../../offline/bin/${arch}/harbor-offline-installer-${harbor_version}.tgz ./
tar -zxvf harbor-offline-installer-${harbor_version}.tgz 
cd harbor
source ../../../conf/config.sh
/bin/cp ../harbor_pre.yml ./harbor.yml

sed -i'' -e "s#\${harbor_hostname}#$harbor_hostname#g" \
           -e "s#\${https_certificate}#$https_certificate#g" \
           -e "s#\${https_private_key}#$https_private_key#g" \
           -e "s#\${harbor_admin_password}#$harbor_admin_password#g" \
           -e "s#\${data_volume}#$data_volume#g" harbor.yml


./prepare
./install.sh


echo "$harbor_ip $harbor_hostname" >> /etc/hosts