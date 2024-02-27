mkdir -p /usr/local/bin/kube-scripts
cat > /usr/local/bin/kube-scripts/k8s-certs-renew.sh <<EOF
#!/bin/bash

echo "## Expiration before renewal ##"
/usr/local/bin/kubeadm certs check-expiration

echo "## Renewing certificates managed by kubeadm ##"
/usr/local/bin/kubeadm certs renew all

echo "## Restarting control plane pods managed by kubeadm ##"
/usr/local/bin/crictl pods --namespace kube-system --name 'kube-scheduler-*|kube-controller-manager-*|kube-apiserver-*|etcd-*' -q | /usr/bin/xargs /usr/local/bin/crictl rmp -f

echo "## Updating /root/.kube/config ##"
/bin/cp /etc/kubernetes/admin.conf /root/.kube/config

echo "## Waiting for apiserver to be up again ##"
until printf "" 2>>/dev/null >>/dev/tcp/127.0.0.1/6443; do sleep 1; done

echo "## Expiration after renewal ##"
/usr/local/bin/kubeadm certs check-expiration
EOF

cat > /etc/systemd/system/k8s-certs-renew.service <<EOF
[Unit]
Description=Renew K8S control plane certificates

[Service]
Type=oneshot
ExecStart=/usr/local/bin/kube-scripts/k8s-certs-renew.sh
EOF
systemctl enable k8s-certs-renew.service


cat > /etc/systemd/system/k8s-certs-renew.timer <<EOF
[Unit]
Description=Timer to renew K8S control plane certificates

[Timer]
OnCalendar=Mon *-*-1,2,3,4,5,6,7 03:00:00
RandomizedDelaySec=3600
FixedRandomDelay=yes
Persistent=true


[Install]
WantedBy=multi-user.target
EOF
systemctl enable k8s-certs-renew.timer
systemctl start k8s-certs-renew.timer