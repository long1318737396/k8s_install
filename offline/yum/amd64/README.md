```bash
cd centos
docker build -t registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64 .
docker run -d --name registry.cn-hangzhou.aliyuncs.com/magictommy/centos8_yum:amd64
```