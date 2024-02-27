apt install conntrack socat ipvsadm ipset git telnet dnsutils nfs-kernel-server nfs-common bash-completion iptables wget -y
yum install conntrack socat ipvsadm ipset git telnet dns-utils nfs-utils bash-completion  wget -y
bash offline/bin/amd64/download-binary-online.sh
hostnamectl set-hostname master1
bash 2.init.sh
bash 3.docker_install.sh
k8s_version=v1.29.2
wget --no-check-certificate https://dl.k8s.io/release/${k8s_version}/bin/linux/amd64/kubeadm
/bin/cp kubeadm /usr/local/bin/
chmod +x /usr/local/bin/kubeadm
bash 6.k8s_install.sh
if [ $? -eq 0 ]; then
  kubectl taint  node  master1 node-role.kubernetes.io/control-plane:NoSchedule-
fi
bash 9.addon_install.sh