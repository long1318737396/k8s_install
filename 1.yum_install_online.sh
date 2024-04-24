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
    net-tools
    nfs-kernel-server
    nfs-common
    unzip
    tar
    bash-completion
    tcpdump
    mtr
    nftables
    iotop
    iptables
    curl
    python3
    iputils-ping
    netcat
  )
  for i in ${packages[@]};do
      apt install $i   -yq --no-install-recommends
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
    net-tools
    bind-utils
    nfs-utils
    unzip
    tar
    bash-completion
    tcpdump
    mtr
    nftables
    iproute-tc
    python3
    iotop
    nc
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
    net-tools
    bind-utils
    nfs-utils
    unzip
    tar
    bash-completion
    tcpdump
    mtr
    nftables
    iproute-tc
    python3
    iotop
    nc
  )

  for i in ${packages[@]};do
      yum install $i  --skip-broken -y
  done
fi