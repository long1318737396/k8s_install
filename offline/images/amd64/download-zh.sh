#!/bin/bash
set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

packages_dir="../../../_output"

mkdir -p ${packages_dir}/images



sed 's/registry\.k8s\.io/k8s.dockerproxy.com/g' base-image.list > image.list

sed 's/registry\.k8s\.io/k8s.dockerproxy.com/g' addon-image.list >> image.list

cat image.list |grep "k8s.dockerproxy.com" > dockerproxy.list

sed 's/k8s\.dockerproxy\.com/registry.k8s.io/g' dockerproxy.list > registry.list


while read line;do docker pull $line ;done < image.list


docker image prune -f

old_prefix="k8s.dockerproxy.com"
new_prefix="registry.k8s.io"

# 获取所有镜像列表，并遍历每个镜像进行重新打标签
docker images --format "{{.Repository}}:{{.Tag}}" | grep "^$old_prefix" | while read -r image; do
    if [[ $image == *"<none>"* ]]; then
        echo "Skipping image with tag <none>: $image"
    else
        new_image=$(echo $image | sed "s/^$old_prefix/$new_prefix/")
        
        # 尝试重新打标签，出错时打印提示信息
        docker tag $image $new_image 2>/dev/null || echo "Failed to tag image: $image"
    fi
done

while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o ${packages_dir}/images/$result.tar.gz $line;done <base-image.list



while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o ${packages_dir}/images/$result.tar.gz $line;done <addon-image.list

docker save -o ${packages_dir}/images/ingress-nginx-controller.tar.gz registry.k8s.io/ingress-nginx/controller:v1.9.6