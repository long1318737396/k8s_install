## node节点扩容


```bash
#配置node4服务器的hostname
hostnamectl set-hostname node4
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
bash 8.join_node.sh
```
上面加入之后可能也是失败的，因为token过期了，需要重新生成token，再次加入

```bash
master1节点拿取加入node的token
kubeadm token create --print-join-command --ttl=1h
```

```bash
#重置本节点
kubeadm reset --force
# 拿到上面打印的命令在node4节点上重新执行
```