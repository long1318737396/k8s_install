set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

packages_dir="../../../_output"

mkdir -p ${packages_dir}/images
while read line;do docker pull $line ;done < base-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o ${packages_dir}/images/$result.tar.gz $line;done <base-image.list


while read line;do docker pull $line ;done < addon-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o ${packages_dir}/images/$result.tar.gz $line;done <addon-image.list

docker save -o ${packages_dir}/images/ingress-nginx-controller.tar.gz registry.k8s.io/ingress-nginx/controller:v1.9.6