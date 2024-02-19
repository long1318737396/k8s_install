source config.sh
mkdir -p $local_dir/images
while read line;do docker pull $line;done < image.list


while read line;do result=$(echo "$line" | awk -F'[/:]' '{ print $(NF-1) }'); docker save -o images/$result.tar.gz $line;done <image.list

tar -czvf images.tar.gz images

for i in `ls addon-image`;do nerdctl load -i addon-image/$i;done
