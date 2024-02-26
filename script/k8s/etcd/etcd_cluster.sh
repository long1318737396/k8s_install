set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

source config.sh

cd ../../../offline/bin/$arch/ 

tar -zxvf etcd-${etcd_version}-linux-${arch}.tar.gz
/bin/cp etcd-${etcd_version}-linux-${arch}/{etcd,etcdutl,etcdctl} /usr/local/bin/
chmod +x /usr/local/bin/{etcd,etcdutl,etcdctl}

cat > /${etcd_ssldir}/conf/config.yml << EOF 
name: 'etcd1'
data-dir: ${etcd_datadir}
wal-dir: ${etcd_datadir}/wal
snapshot-count: 50000
heartbeat-interval: 100
election-timeout: 1000
quota-backend-bytes: 32768000000
auto-compaction-mode: periodic
auto-compaction-retention: 1000
auto-compaction-interval: 1h
listen-peer-urls: 'https://${etcd1_ip}:2380'
listen-client-urls: 'https://${etcd1_ip}:2379,https://127.0.0.1:2379'
max-snapshots: 3
max-wals: 5
cors:
initial-advertise-peer-urls: 'https://${etcd1_ip}:2380'
advertise-client-urls: 'https://${etcd1_ip}:2379,https://127.0.0.1:2379'
discovery:
discovery-fallback: 'proxy'
discovery-proxy:
discovery-srv:
initial-cluster: 'etcd1=https://${etcd1_ip}:2380,etcd2=https://${etcd2_ip}:2380,etcd3=https://${etcd3_ip}:2380'
initial-cluster-token: 'etcd-k8s-cluster'
initial-cluster-state: 'new'
strict-reconfig-check: false
enable-v2: true
enable-pprof: true
proxy: 'off'
proxy-failure-wait: 5000
proxy-refresh-interval: 30000
proxy-dial-timeout: 1000
proxy-write-timeout: 5000
proxy-read-timeout: 0
client-transport-security:
  cert-file: '${etcd_ssldir}/ssl/etcd-server.pem'
  key-file: '${etcd_ssldir}/ssl/etcd-server-key.pem'
  client-cert-auth: true
  trusted-ca-file: '${etcd_ssldir}/ssl/etcd-ca.pem'
  auto-tls: true
peer-transport-security:
  cert-file: '${etcd_ssldir}/ssl/etcd-server.pem'
  key-file: '${etcd_ssldir}/ssl/etcd-server-key.pem'
  client-cert-auth: true
  trusted-ca-file: '${etcd_ssldir}/ssl/etcd-ca.pem'
  auto-tls: true
debug: false
log-package-levels:
log-outputs: [default]
force-new-cluster: false
EOF



cat > /usr/lib/systemd/system/etcd.service <<EOF
[Unit]
Description=Etcd Service
Documentation=https://coreos.com/etcd/docs/latest/
After=network.target

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd --config-file=${etcd_ssldir}/conf/config.yml
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
Alias=etcd1.service
EOF

# 启动 etcd 
systemctl daemon-reload
systemctl start etcd
systemctl enable etcd

