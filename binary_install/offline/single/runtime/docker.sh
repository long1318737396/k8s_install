source config.cfg

cd ${download_dir}
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


docker completion bash > /etc/profile.d/docker.sh
tar xvf cri-dockerd-*.amd64.tgz 
cp  cri-dockerd/cri-dockerd  ${bin_dir}/
chmod +x ${bin_dir}/cri-dockerd

cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket

[Service]
Type=notify
ExecStart=${bin_dir}/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service

[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
systemctl daemon-reload
systemctl enable --now cri-docker.service
systemctl restart cri-docker.service
systemctl enable docker --now