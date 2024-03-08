set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

docker build -t registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64 .
docker run -d --name yum8 registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64
docker exec yum8 /bin/sh -c "cd  /usr/share/nginx/html;tar -czvf rpms.tar.gz rpms/"
docker cp yum8:/usr/share/nginx/html/rpms.tar.gz .
if [ $? -ne 0 ];then
    echo "build yum8 failed"
    exit 1
fi
docker rm -f yum8
mv rpms.tar.gz ../