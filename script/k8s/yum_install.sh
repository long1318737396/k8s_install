set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/yum/${arch}/centos8

tar -zxvf rpms.tar.gz

local_repo=$(pwd)/rpms
timestamp=$(date +"%Y-%m-%d-%H-%M-%S")

mv /etc/yum.repos.d /etc/yum.repos.d_bak_old_$timestamp
mkdir /etc/yum.repos.d

tee /etc/yum.repos.d/local.repo <<EOF
[local]
name=local
baseurl=file://$local_repo
gpgcheck=0
enabled=1
EOF

yum makecache
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