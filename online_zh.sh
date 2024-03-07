if [ -f /etc/debian_version ]; then
  apt update
   packages=(
    wget* 
    vim* 
    conntrack* 
    socat* 
    ipvsadm* 
    ipset* 
    nmap* 
    telnet* 
    dnsutils*  
    nfs-kernel-server
    nfs-common
    unzip* 
    bash-completion* 
    tcpdump* 
    mtr* 
    nftables* 
    iproute-tc*
    iptables
    curl
    git
  )
  for i in ${packages[@]};do
      apt install $i   -y
  done
elif [ -f /etc/redhat-release ]; then
  packages=(
    wget* 
    vim* 
    conntrack* 
    socat* 
    ipvsadm* 
    ipset* 
    nmap* 
    telnet* 
    bind-utils*  
    nfs-utils* 
    unzip* 
    bash-completion* 
    tcpdump* 
    mtr* 
    nftables* 
    iproute-tc*
  )

  for i in ${packages[@]};do
      yum install $i  --skip-broken -y
  done
else
    packages=(
    wget* 
    vim* 
    conntrack* 
    socat* 
    ipvsadm* 
    ipset* 
    nmap* 
    telnet* 
    bind-utils*  
    nfs-utils* 
    unzip* 
    bash-completion* 
    tcpdump* 
    mtr* 
    nftables* 
    iproute-tc*
  )

  for i in ${packages[@]};do
      yum install $i  --skip-broken -y
  done
fi
bash offline/bin/amd64/download-binary-online-zh.sh
if [ $? -ne 0 ]; then
  echo "相关文件下载失败请检查"
  exit 1
fi
bash 2.init.sh

bash script/k8s/8.nfs-install-zh.sh
if [ $? -ne 0 ]; then
  echo "nfs安装失败请检查"
  exit 1
fi


bash 3.docker_install.sh
if [ $? -ne 0 ]; then
  echo "docker安装失败，请查看相关日志解决，然后重新安装"
  exit 1
fi

sed -i 's#registry.k8s.io/pause:3.9#registry.aliyuncs.com/google_containers/pause:3.9#' /etc/containerd/config.toml
systemctl daemon-reload
systemctl restart containerd


bash script/k8s/2.kubeadm-install-zh.sh
if [ $? -ne 0 ]; then
  echo "kubeadm初始化失败请检查"
  exit 1
fi
hostnamectl set-hostname master1
bash script/k8s/3.k8s-install-zh.sh
if [ $? -ne 0 ]; then
  echo "k8s安装失败，请查看相关日志解决，然后执行kubeadm reset --force重置重新安装"
  exit 1
fi
if [ $? -eq 0 ]; then
  kubectl taint  node  master1 node-role.kubernetes.io/control-plane:NoSchedule-
fi
bash script/k8s/4.net-work.sh
if [ $? -ne 0 ]; then
  echo "网络组件安装失败，请检查"
  exit 1
fi
bash script/k8s/5.addon-zh.sh
if [ $? -ne 0 ]; then
  echo "有组件安装失败，请手动更改"
  exit 1
fi
kubectl set image ds -n  environment ingress-nginx-controller controller=k8s.dockerproxy.com/ingress-nginx/controller:v1.9.6
kubectl set image deployment -n environment  prometheus-kube-state-metrics kube-state-metrics=k8s.dockerproxy.com/kube-state-metrics/kube-state-metrics:v2.10.1
kubectl set image deployments.apps -n kube-system metrics-server metrics-server=k8s.dockerproxy.com/metrics-server/metrics-server:v0.7.0