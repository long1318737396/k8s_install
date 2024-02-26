set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh


exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


for i in `ls |grep tar.gz`;do nerdctl load -i $i;done
