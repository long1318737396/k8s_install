set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


while read line;do nerdctl pull $line --insecure-registry;done < base-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); nerdctl save -o $result.tar.gz $line;done <base-image.list


while read line;do nerdctl pull $line --insecure-registry;done < addon-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); nerdctl save -o $result.tar.gz $line;done <addon-image.list