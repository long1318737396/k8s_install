set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh


exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


destination=myharbor.mtywcloud.com/library
while read line; \
  do nerdctl tag $line ${destination}/${line##*/}; \
     echo "----nerdctl tag $line ${destination}/${line##*/}-----"; \
    nerdctl push --insecure-registry ${destination}/${line##*/}; \
    echo "----nerdctl push --insecure-registry ${destination}/${line##*/}----"; \
  done <base-image.list

while read line; \
  do nerdctl tag $line ${destination}/${line##*/}; \
     echo "----nerdctl tag $line ${destination}/${line##*/}-----"; \
    nerdctl push --insecure-registry ${destination}/${line##*/}; \
    echo "----nerdctl push --insecure-registry ${destination}/${line##*/}----"; \
  done <addon-image.list