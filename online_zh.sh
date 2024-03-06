if [ -f /etc/debian_version ]; then
  apt update
  apt install conntrack socat ipvsadm ipset git telnet dnsutils nfs-kernel-server nfs-common bash-completion iptables wget -y
elif [ -f /etc/redhat-release ]; then
  yum install conntrack socat ipvsadm ipset git telnet dns-utils nfs-utils bash-completion  wget -y
else
    yum install conntrack socat ipvsadm ipset git telnet dns-utils nfs-utils bash-completion  wget -y
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