set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

set +e
while read line;do docker pull $line ;done < base-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o $result.tar.gz $line;done <base-image.list


while read line;do docker pull $line ;done < addon-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o $result.tar.gz $line;done <addon-image.list