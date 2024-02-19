source config.cfg
cd ${download_dir}

cri_o_version=1.29.1
wget https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.v${cri_o_version}.tar.gz
tar -zxvf cri-o.amd64.v${cri_o_version}.tar.gz
cd cri-o
./install
cat > /etc/crio/crio.conf <<EOF
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "systemd"
[crio.image]
pause_image="registry.k8s.io/pause:3.9"
EOF

# cat > /etc/crictl.yaml <<EOF
# runtime-endpoint: unix:///var/run/crio/crio.sock
# image-endpoint: unix:///var/run/crio/crio.sock
# timeout: 30
# debug: false
# EOF
sudo systemctl daemon-reload
sudo systemctl enable --now crio