set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

bash script/harbor/create_cert.sh
bash script/harbor/install_harbor.sh