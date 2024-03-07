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
bash offline/bin/amd64/download-binary-online.sh
hostnamectl set-hostname master1
bash 2.init.sh
bash 3.docker_install.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
k8s_version=v1.29.2
wget --no-check-certificate https://dl.k8s.io/release/${k8s_version}/bin/linux/amd64/kubeadm
/bin/cp kubeadm /usr/local/bin/
chmod +x /usr/local/bin/kubeadm
bash 6.k8s_install.sh
if [ $? -ne 0 ]; then
  echo "k8s安装失败，请查看相关日志解决，然后执行kubeadm reset --force重置重新安装"
  exit 1
fi
if [ $? -eq 0 ]; then
  kubectl taint  node  master1 node-role.kubernetes.io/control-plane:NoSchedule-
fi
bash 9.addon_install.sh