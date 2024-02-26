set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/yum/${arch}/centos8

tar -zxvf rpms.tar.gz

cd rpms
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

    yum localinstall $i  --skip-broken -y
done