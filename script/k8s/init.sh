set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

#apt install -y wget
sed -i 's/.*swap.*/#&/' /etc/fstab
swapoff -a && sysctl -w vm.swappiness=0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld

tee /etc/modules-load.d/10-k8s-modules.conf <<EOF
sunrpc
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
br_netfilter
nf_conntrack
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
EOF
systemctl restart systemd-modules-load

tee /etc/sysctl.d/95-k8s-sysctl.conf <<EOF
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
# see details in https://help.aliyun.com/knowledge_detail/39428.html
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
# see details in https://help.aliyun.com/knowledge_detail/41334.html
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.ip_forward = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_tw_reuse = 0
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-arptables = 1
net.core.somaxconn = 32768
net.netfilter.nf_conntrack_max = 524288
fs.nr_open = 6553600
fs.file-max = 6553600
vm.max_map_count = 655360
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 10
vm.overcommit_memory = 1
kernel.panic = 10
kernel.panic_on_oops = 1
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1048576
fs.inotify.max_queued_events = 1048576
fs.pipe-user-pages-soft=102400
EOF
sysctl -p /etc/sysctl.d/95-k8s-sysctl.conf


if [[  -f /etc/resolv.conf ]]
then
  echo "resolv is existing"
else
  tee /etc/resolv.conf <<EOF
nameserver 10.96.0.11
search default.svc.cluster.local svc.cluster.local
options timeout:2 attempts:3 rotate single-request-reopen
EOF
fi