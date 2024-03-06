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
  echo "Command failed. Exiting..."
  exit 1
fi
bash 2.init.sh

bash 3.docker_install.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi

bash script/k8s/2.kubeadm-install-zh.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
hostnamectl set-hostname master1
bash script/k8s/3.k8s-install-zh.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
if [ $? -eq 0 ]; then
  kubectl taint  node  master1 node-role.kubernetes.io/control-plane:NoSchedule-
fi
bash script/k8s/4.net-work.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
bash script/k8s/5.addon-zh.sh
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi