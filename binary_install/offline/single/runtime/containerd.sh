source config.cfg
cd ${download_dir}


tar zxvf nerdctl-full-${nerdctl_full_version}.tar.gz -C /usr/local/
cp /usr/local/lib/systemd/system/*.service /etc/systemd/system/


mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep SystemdCgroup
#sed -i "s#registry.k8s.io#m.daocloud.io/registry.k8s.io#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep sandbox_image
sed -i "s#config_path\ \=\ \"\"#config_path\ \=\ \"/etc/containerd/certs.d\"#g" /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep certs.d
mkdir /etc/containerd/certs.d/docker.io -pv
cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://docker.mirrors.ustc.edu.cn"]
  capabilities = ["pull", "resolve"]
EOF

mkdir -p /opt/cni/bin
cp /usr/local/libexec/cni/* /opt/cni/bin/



cp docker-compose-linux-x86_64 /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


tar -zxvf docker-${docker_version}.tgz 
cp docker/docker* /usr/local/bin/

sudo cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP $MAINPID
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
    "insecure-registries" : ["registry.mydomain.com:5000"],
    "log-driver": "json-file",
    "data-root": "${docker_runtime_dir}",
    "log-opts": {
        "max-size": "100m",
        "max-file": "10"
    },
    "bip": "169.254.123.1/24",
    "registry-mirrors": ["https://xbrfpgqk.mirror.aliyuncs.com"],
    "live-restore": true
}
EOF


systemctl enable buildkit containerd 
systemctl start buildkit containerd 
systemctl enable docker --now
docker completion bash > /etc/profile.d/docker.sh

echo "source <(crictl completion bash)" >> ~/.bashrc

echo "runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:////var/run/containerd/containerd.sock
#runtime-endpoint: unix:///var/run/crio/crio.sock
timeout: 10
#debug: true"  > /etc/crictl.yaml


#systemctl status buildkit containerd
echo "source <(nerdctl completion bash)" >> ~/.bashrc