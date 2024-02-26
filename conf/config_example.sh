#------------harbor配置-----------
harbor_ip=172.21.62.138   #harbor的ip
harbor_hostname=myharbor.mtywcloud.com   #harbor的域名
https_certificate=/etc/harbor/cert/${harbor_hostname}.crt   #https证书
https_private_key=/etc/harbor/cert/${harbor_hostname}.key   #https私钥
data_volume=/data/harbor/registry         #harbor数据目录
harbor_admin_password=S6ag4KXGS   #harbor管理员密码
#------------docker配置-----------
docker_data_root="/data/kubernetes/docker"       #docker数据目录
#----------containerd配置---------
containerd_data_dir="/data/kubernetes/containerd"          #containerd数据目录
#------------k8s配置--------------
master1_ip=172.16.10.206   #master1的ip
master2_ip=192.168.1.212   #master2的ip
master3_ip=192.168.1.213   #master3的ip
kubeadm_dir="/usr/local/bin"        #kubeadm目录
etcd_data_dir="/data/kubernetes/etcd"     #etcd数据目录             
pod_cidr="10.244.0.0/16"             #pod 网段
svc_cidr="10.96.0.0/20"              #service网段
kube_vip_enable=false                 #是否启用kube-vip，类似是否配置keepalived实现虚拟IP的高可用,如果是true，则必须配置loadbalancer_vip，如果是外部负载均衡需要设置为false，但也需要配置loadbalancer_vip
loadbalancer_vip=172.16.10.206        #kube-vip的虚拟IP
kube_vip_eth="ens192"                  #kube-vip使用的网卡，启用kube-vip则必须配置
node_cidr_mask_size="25"            #每个节点所分配的网段掩码
#------------网络插件配置----------
network_type="cilium"               #网络插件类型
#------------其他配置-------------
nfs_enabled="true"   #是否部署nfs
nfs_server="192.168.1.12"  #nfs服务器地址
nfs_path="/data/nfs/k8s"   #nfs目录
logfile=/var/log/k8s_install.log
date_format=$(date +"%Y-%m-%d %H:%M:%S")
#---------cpu架构配置------------
arch="amd64"  #arm64
arch1="x86_64"  #aarch64
#------------组件版本配置--------------
kernel_version='5.4.260'
runc_version='1.1.12'
docker_version='25.0.3'
cni_plugins_version='v1.4.0'
containerd_version='1.7.13'
nerdctl_full_version='1.7.4'
crictl_version='v1.29.0'
cri_dockerd_version='0.3.10'
etcd_version='v3.5.12'
cfssl_version='1.6.4'
helm_version='3.14.1'
kubernetes_server_version='1.29.2'
kubernetes_client_version='1.29.2'
nginx_version='1.25.3'
cri_o_version='V1.29.1'
docker_compose_version='v2.24.6'
harbor_version='v2.9.2'
calicoctl_version=3.27.2
cilium_version=v0.15.23
hubble_version=v0.13.0
velero_version=v1.13.0
skopeo_version=v1.14.2
yq_version=v4.41.1