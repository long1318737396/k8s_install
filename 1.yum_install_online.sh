if [ -f /etc/debian_version ]; then
  apt update
   packages=(
    wget
    vim 
    conntrack
    socat
    ipvsadm 
    ipset
    nmap 
    telnet 
    dnsutils  
    nfs-kernel-server
    nfs-common
    unzip
    tar
    bash-completion 
    tcpdump
    mtr
    nftables 
    iproute-tc
    iptables
    curl
    git
  )
  for i in ${packages[@]};do
      apt install $i   -y
  done
elif [ -f /etc/redhat-release ]; then
  packages=(
    wget
    vim 
    conntrack
    socat
    ipvsadm 
    ipset
    nmap 
    telnet 
    bind-utils  
    nfs-utils 
    unzip
    tar
    bash-completion 
    tcpdump
    mtr
    nftables 
    iproute-tc
  )

  for i in ${packages[@]};do
      yum install $i  --skip-broken -y
  done
else
    packages=(
    wget
    vim 
    conntrack 
    socat
    ipvsadm 
    ipset
    nmap 
    telnet 
    bind-utils  
    nfs-utils 
    unzip
    tar
    bash-completion 
    tcpdump
    mtr
    nftables 
    iproute-tc
  )

  for i in ${packages[@]};do
      yum install $i  --skip-broken -y
  done
fi