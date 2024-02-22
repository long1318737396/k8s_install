arch=amd64
local_dir="/data/kubernetes/images"
mkdir -p $local_dir/amd
#mkdir -p $local_dir/arm
while read line;do docker pull $line;done < base-image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o $local_dir/amd/$result.tar.gz $line;done <base-image.list

#tar -czvf images.tar.gz images

#for i in `ls addon-image`;do nerdctl load -i addon-image/$i;done
