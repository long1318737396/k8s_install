## 在线安装

- 海外机器

```bash
yum install git -y
git clone https://github.com/long1318737396/k8s_install.git
cd k8s_install
vi conf/config.sh
#配置master1_ip 以及loadbalancer_vip kube_vip_enable=false
bash online.sh
```

- 国内机器

```bash
yum install git -y
git clone https://github.com/long1318737396/k8s_install.git
cd k8s_install
vi conf/config.sh
#配置master1_ip 以及loadbalancer_vip kube_vip_enable=false
bash online_zh.sh
```

## 开启证书自动轮转
```bash
bash cert_autorenew.sh
```

## 开启etcd的备份

```bash
bash etcd_backup.sh
```