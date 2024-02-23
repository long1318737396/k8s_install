tar -zxvf registry_2.8.3_linux_amd64.tar.gz
cp registry /usr/local/bin/
chmod +x /usr/local/bin/registry
cd ../
mkdir /etc/registry
/bin/cp conf/registry.yml /etc/registry/registry.yml
cat > /usr/lib/systemd/system/registry.service <<EOF
[Unit]
Description=registry  
Documentation=https://github.com/distribution/distribution
Wants=network-online.target
After=network-online.target
[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/registry serve  /etc/registry/registry.yml
[Install]
WantedBy=multi-user.target
EOF
systemctl enable registry
systemctl start registry
