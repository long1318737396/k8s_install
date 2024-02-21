#------------harbor配置-----------
hostname=myharbor.mtywcloud.com   #harbor的域名
https_certificate=/data/harbor/   #https证书
https_private_key=/data/harbor/   #https私钥
data_volume=/data/harbor          #harbor数据目录
harbor_version=2.9.2              #harbor版本
harbor_admin_password=S6ag4KXGS   #harbor管理员密码
#------------docker配置-----------
docker_version="24.0.7"            #docker版本
docker_data_root="/data/kubernetes/docker"       #docker数据目录
#----------containerd配置---------
containerd_version="1.7.1"          #containerd版本
containerd_data_dir="/data/kubernetes/containerd"          #containerd数据目录
#------------k8s配置--------------
etcd_version="v3.5.10"             #etcd版本
k8s_version="v1.29.0"              #k8s版本
crictl_version="1.29.0"            #crictl版本
kubeadm_dir="/usr/local/bin"        #kubeadm目录
etcd_data_dir="/data/kubernetes/etcd"     #etcd数据目录             
pod_cidr="10.244.0.0/16"             #pod 网段
svc_cidr="10.96.0.0/20"              #service网段
kube_vip_enable=true                 #是否启用kube-vip，类似是否配置keepalived实现虚拟IP的高可用
kube_vip=                            #kube-vip的虚拟IP
kube_vip_eth="eth0"                  #kube-vip使用的网卡
#------------网络插件配置----------
cilium_cli_version=""               #cilium-cli版本
hubble_version=""                   #hubble版本
calico_version="3.26.4"             #calico版本
cni_version="1.4.0"                 #cni版本
network_type="cilium"               #网络插件类型
#------------组件配置--------------
helm_version="3.13.3"               #helm版本
#------------其他配置-------------
download_ip=172.21.62.138
download_software_url="http://${download_ip}:8089/${arch}/software"
download_yaml_url="http://${download_ip}:8089/${arch}/yaml"
download_conf_url="http://${download_ip}:8089/${arch}/conf"
download_image_url="http://${download_ip}:8089/${arch}/images"
registry="registry.mydomain.com:5000"
local_dir="/data/kubernetes/software"
arch="amd64"
logfile=/var/log/k8s_install.log
date_format=$(date +"%Y-%m-%d %H:%M:%S")



