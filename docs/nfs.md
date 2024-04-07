登录nfs服务器，或者复用k8s节点的服务器、harbor服务器

nfs需要为后续的监控组件、日志组件等提供持久化存储

如果机器可以联网，可以在线安装所需的软件包
```bash
if [ -f /etc/debian_version ]; then
  apt update && apt install nfs-kernel-server -y
  systemctl enable nfs-kernel-server
  systemctl restart nfs-kernel-server

elif [ -f /etc/redhat-release ]; then
  yum install nfs-utils -y
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
else
  yum install nfs-utils -y
  systemctl enable rpcbind --now
  systemctl enable nfs-server
  systemctl start nfs-server
fi
```

**如果无法联网，则需要手动安装软件包** 

[rpm包获取指南](./rpm_offline.md)


配置nfs服务
```bash
harbor_ip=192.168.150.14
curl -L -o k8s_install.tar.gz $harbor_ip:38088/k8s_install.tar.gz
tar -zxvf k8s_install.tar.gz
cd k8s_install
#确认配置文件，可以直接复制安装harbor时的配置文件
vi conf/config.sh
bash script/k8s/8.nfs-install.sh
```