set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

bash script/k8s/yum_install.sh