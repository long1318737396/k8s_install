source config.cfg
apt update && apt upgrade -y && apt install -y wget psmisc vim net-tools nfs-kernel-server telnet lvm2 git tar curl

yum update -y && yum -y install  wget psmisc vim net-tools nfs-utils telnet yum-utils device-mapper-persistent-data lvm2 git tar curl

systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
hostnamectl set-hostname ${master1_hostname}

cat >> /etc/hosts << EOF
${master1_ip} ${master1_hostname}
EOF

cat > /etc/sysctl.d/k8s.conf << EOF
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
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
ulimit -SHn 65535
cat >> /etc/security/limits.conf <<EOF
* soft nofile 655360
* hard nofile 131072
* soft nproc 655350
* hard nproc 655350
* seft memlock unlimited
* hard memlock unlimitedd
EOF
sysctl --system  # 生效
yum install ntpdate -y
ntpdate ntp.aliyun.com

tee /etc/modules-load.d/10-k8s-modules.conf <<EOF
sunrpc
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
ip_vs_lc
overlay
br_netfilter
nf_conntrack
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF
systemctl restart systemd-modules-load