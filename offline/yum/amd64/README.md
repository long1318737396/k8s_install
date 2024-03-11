```bash
cd offline/yum/amd64/centos8
vi pkg.list #查看包列表,添加需要的软件包
docker build -t registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64 .
docker run -d --name yum8 registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64
docker exec yum8 /bin/sh -c "cd  /usr/share/nginx/html;tar -czvf rpms.tar.gz rpms/"
docker cp yum8:/usr/share/nginx/html/rpms.tar.gz .
if [ $? -ne 0 ];then
    echo "build yum8 failed"
    exit 1
fi
docker rm -f yum8
```