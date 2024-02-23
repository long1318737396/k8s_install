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
/bin/cp ../harbor_pre.yml ./

envsubst < harbor_pre.yml > harbor.yml

./prepare
./install.sh