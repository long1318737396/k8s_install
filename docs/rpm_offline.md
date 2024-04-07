## 通过docker拉取需要的rpm、deb软件包



### 制作关于anolisos8.8的rpm软件包

```bash
export BUILD_NUMBER=20230801
pkg=(curl vim conntrack socat ipvsadm ipset telnet nfs-utils unzip tar bash-completion tcpdump mtr iproute-tc)
mkdir -p /data/ftp/rpms/anolisos8.8-${BUILD_NUMBER}
cd /data/ftp/rpms/anolisos8.8-${BUILD_NUMBER}
docker run -d --name anolisos8.8-${BUILD_NUMBER} registry.openanolis.cn/openanolis/anolisos:8.8 sleep infinity

for i in ${pkg[@]};do
  docker exec anolisos8.8-${BUILD_NUMBER} mkdir -p ${BUILD_NUMBER}/$i
  docker exec anolisos8.8-${BUILD_NUMBER} yum install --downloadonly --downloaddir=${BUILD_NUMBER}/$i $i -y

done

docker exec anolisos8.8-${BUILD_NUMBER} tar -czvf anolisos8.8-${BUILD_NUMBER}.tar.gz ${BUILD_NUMBER}
docker cp anolisos8.8-${BUILD_NUMBER}:/anolisos8.8-${BUILD_NUMBER}.tar.gz ./
chmod -R  755  /data/ftp/rpms/anolisos8.8-${BUILD_NUMBER}
echo "请在/data/ftp/rpms/anolisos8.8-${BUILD_NUMBER}拿去软件包"
```


### 制作关于麒麟v10 sp3的rpm软件包

```bash
export BUILD_NUMBER=20230801
pkg=(curl vim conntrack socat ipvsadm ipset telnet nfs-utils unzip tar bash-completion tcpdump mtr iproute-tc)
mkdir -p /data/ftp/rpms/v10-sp3-docker-lance-${BUILD_NUMBER}
cd /data/ftp/rpms/v10-sp3-docker-lance-${BUILD_NUMBER}
docker run -d --name v10-sp3-docker-lance-${BUILD_NUMBER} registry.cn-hangzhou.aliyuncs.com/magictommy/kylin:v10-sp3-docker-lance sleep infinity

for i in ${pkg[@]};do
  docker exec v10-sp3-docker-lance-${BUILD_NUMBER} mkdir -p ${BUILD_NUMBER}/$i
  docker exec v10-sp3-docker-lance-${BUILD_NUMBER} yum install --downloadonly --downloaddir=${BUILD_NUMBER}/$i $i -y

done

docker exec v10-sp3-docker-lance-${BUILD_NUMBER} tar -czvf v10-sp3-docker-lance-${BUILD_NUMBER}.tar.gz ${BUILD_NUMBER}
docker cp v10-sp3-docker-lance-${BUILD_NUMBER}:/v10-sp3-docker-lance-${BUILD_NUMBER}.tar.gz ./
chmod -R  755  /data/ftp/rpms/v10-sp3-docker-lance-${BUILD_NUMBER}
echo "请在/data/ftp/rpms/v10-sp3-docker-lance-${BUILD_NUMBER}拿去软件包"
```

### 拷贝至目标服务器上进行安装

```bash
yum localinstall *.rpm
```

### 制作关于Ubuntu22.04的deb软件包

```bash
export BUILD_NUMBER=20230801
pkg=(curl vim conntrack socat ipvsadm ipset telnet nfs-server nfs-common unzip tar bash-completion tcpdump mtr)
mkdir -p /data/ftp/debs/ubuntu22.04-${BUILD_NUMBER}
cd /data/ftp/debs/ubuntu22.04-${BUILD_NUMBER}
docker run -d --name ubuntu22.04-${BUILD_NUMBER} ubuntu:22.04 sleep infinity


docker exec ubuntu22.04-${BUILD_NUMBER} apt update

for i in ${pkg[@]}; do
  docker exec ubuntu22.04-${BUILD_NUMBER} mkdir -p /${BUILD_NUMBER}/$i
  docker exec ubuntu22.04-${BUILD_NUMBER} chmod -R 777 /${BUILD_NUMBER}/$i
  docker exec ubuntu22.04-${BUILD_NUMBER} /bin/bash -c "cd /${BUILD_NUMBER}/$i && apt-get download \$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $i | grep '^\w' | sort -u)"
done

docker exec ubuntu22.04-${BUILD_NUMBER} tar -czvf ubuntu22.04-${BUILD_NUMBER}.tar.gz ${BUILD_NUMBER}
docker cp ubuntu22.04-${BUILD_NUMBER}:/ubuntu22.04-${BUILD_NUMBER}.tar.gz ./
chmod -R 755 /data/ftp/debs/ubuntu22.04-${BUILD_NUMBER}
echo "请在/data/ftp/debs/ubuntu22.04-${BUILD_NUMBER}拿取软件包"
docker rm -f ubuntu22.04-${BUILD_NUMBER}
```

### 拷贝至目标服务器上进行安装

```bash
dpkg -i *.deb
```