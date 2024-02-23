```bash
cd centos
docker build -t registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64 .
docker run -d --name yum8 registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64
docker exec yum8 /bin/sh -c "cd  /usr/share/nginx/html;tar -czvf rpms.tar.gz rpms/"
docker cp yum8:/usr/share/nginx/html/rpms.tar.gz .
```