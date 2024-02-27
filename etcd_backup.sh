mkdir -p /usr/local/bin/kube-scripts

/bin/cp script/k8s/etcd/etcd_backup.sh /usr/local/bin/kube-scripts/etcd_backup.sh


tee /etc/systemd/system/backup-etcd.service <<EOF
[Unit]
Description=Backup ETCD
[Service]
Type=oneshot
ExecStart=/usr/local/bin/kube-scripts/etcd_backup.sh
EOF
systemctl enable backup-etcd.service

tee /etc/systemd/system/backup-etcd.timer <<EOF
[Unit]
Description=Timer to backup ETCD
[Timer]
#OnCalendar=*-*-* 02:00:00
OnCalendar=*-*-01 02:00:00
RandomizedDelaySec=3600
FixedRandomDelay=yes
Persistent=true
Unit=backup-etcd.service
[Install]
WantedBy=multi-user.target
EOF
systemctl enable backup-etcd.timer
systemctl start backup-etcd.timer