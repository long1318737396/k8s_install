#------------harbor配置-----------
harbor_ip=192.168.150.14
harbor_hostname=myharbor.mtywcloud.com
https_certificate=/etc/harbor/cert/${harbor_hostname}.crt
https_private_key=/etc/harbor/cert/${harbor_hostname}.key
data_volume=/data/harbor/registry
harbor_admin_password=S6ag4KXGS
#------------docker配置-----------
docker_data_root="/data/kubernetes/docker"
#----------containerd配置---------
containerd_data_dir="/data/kubernetes/containerd"
#------------k8s配置--------------
master1_ip=192.168.150.10
master2_ip=192.168.150.11
master3_ip=192.168.150.12
kubeadm_dir="/usr/local/bin"
etcd_data_dir="/data/kubernetes/etcd"           
pod_cidr="10.244.0.0/16"
svc_cidr="10.96.0.0/20"
kube_vip_enable=true
loadbalancer_vip=192.168.150.15
kube_vip_eth="ens160"
node_cidr_mask_size="25"
#------------网络插件配置----------
network_type="cilium"
#------------其他配置-------------
nfs_enabled=true
nfs_server="192.168.150.14"
nfs_path=/data/nfs/k8s
logfile=/var/log/k8s_install.log
date_format=$(date +"%Y-%m-%d %H:%M:%S")
#----------apollo安装配置------------
apollo_db_host=1.1.1.1
apollo_db_username=sa
apollo_db_password=test
apollo_db_port=3306
apollo_configdb_name=ApolloConfigDB
apollo_portdb_name=ApolloPortalDB
#---------cpu架构配置------------
arch="amd64"
arch1="x86_64"
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
jq_version=1.7.1