## master节点扩容

```bash
#配置master4服务器的hostname
hostnamectl set-hostname master4
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
unzip -j offline/bin/amd64/bin.zip -d offline/bin/amd64/
unzip -j offline/images/amd64/images.zip -d offline/images/amd64/
#修改配置文件，可以复用在harbor安装时的配置文件
vi conf/config.sh
#依次执行
#离线安装k8s所需软件包，某些安装失败则需要自行找相应软件包安装，脚本会配置yum本地目录做为仓库
bash 1.yum_install.sh
bash 2.init.sh
bash 3.docker_install.sh
bash offline/images/amd64/load.sh
bash 7.join_master.sh
```
这个时候加入已有集群可能是失败的，因为token过期了，需要重新生成token，再次加入

```bash
#重置本节点
kubeadm --reset --force
```

在master1节点拿取加入控制面的token
```bash
#可以使用下面命令生成新证书上传，这里会打印出certificate key，后面会用到
CERT_KEY=`kubeadm init phase upload-certs --upload-certs|tail -1`
# 其中 --ttl=0 表示生成的 token 永不失效. 如果不带 --ttl 参数, 那么默认有效时间为24小时. 在24小时内, 可以无数量限制添加 worker.
echo `kubeadm token create --print-join-command --ttl=1h` " --control-plane --certificate-key $CERT_KEY --v=5"
# 拿到上面打印的命令在master4节点上重新执行
```