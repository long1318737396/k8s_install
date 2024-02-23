set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

nerdctl login $harbor_hostname --username admin --password $harbor_admin_password
nerdctl pull myharbor.mtywcloud.com/library/nginx:latest --insecure-registry