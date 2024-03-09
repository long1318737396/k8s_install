set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../offline/bin/${arch}
tar zxvf nerdctl-full-${nerdctl_full_version}-linux-${arch}.tar.gz -C /usr/local/
/bin/cp /usr/local/lib/systemd/system/*.service /etc/systemd/system/
systemctl enable buildkit containerd 

echo "source <(nerdctl completion bash)" > /etc/profile.d/nerdctl.sh

mkdir -p /etc/containerd/

/bin/cp ../../../conf/containerd.toml  /etc/containerd/config.toml
# containerd config default > /etc/containerd/config.toml
# sed -i 's/SystemdCgroup\ =\ false/SystemdCgroup\ =\ true/g' /etc/containerd/config.toml
sed -i "s@\${containerd_data_dir}@${containerd_data_dir}@g" /etc/containerd/config.toml


mkdir -p /etc/containerd/certs.d/${harbor_hostname}
/bin/cp ../../../conf/hosts.toml /etc/containerd/certs.d/${harbor_hostname}/
sed -i "s@\${harbor_hostname}@${harbor_hostname}@g" /etc/containerd/certs.d/${harbor_hostname}/hosts.toml

systemctl start buildkit containerd 
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
mkdir -p /opt/cni/bin
/bin/cp /usr/local/libexec/cni/* /opt/cni/bin/


echo "source <(crictl completion bash)" > /etc/profile.d/crictl.sh

echo "runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:////var/run/containerd/containerd.sock
#runtime-endpoint: unix:///var/run/crio/crio.sock
timeout: 10
#debug: true"  > /etc/crictl.yaml

mkdir -p /etc/buildkit
/bin/cp ../../../conf/buildkitd.toml /etc/buildkit/buildkitd.toml
mkdir -p /etc/nerdctl/
/bin/cp ../../../conf/nerdctl.toml /etc/nerdctl/nerdctl.toml

/bin/cp docker-compose-linux-${arch1} /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose



tar -zxvf docker-${docker_version}.tgz 
/bin/cp docker/docker* /usr/local/bin/

sudo cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
[Install]
WantedBy=multi-user.target
EOF

mkdir /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
 {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "insecure-registries" : ["myharbor.mtywcloud.com"],
    "log-driver": "json-file",
    "data-root": "${docker_data_root}",
    "log-opts": {
        "max-size": "100m",
        "max-file": "10"
    },
    "bip": "169.254.123.1/24",
    "registry-mirrors": ["https://xbrfpgqk.mirror.aliyuncs.com"],
    "live-restore": true
}
EOF
sed -i "s@\${docker_data_root}@${docker_data_root}@g" /etc/docker/daemon.json
systemctl enable docker --now
if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi
docker completion bash > /etc/profile.d/docker.sh
#source /etc/profile.d/docker.sh

