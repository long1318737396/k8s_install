source config.cfg
cd ${download_dir}
mkdir ssl

cp cfssl_*_linux_amd64 /usr/local/bin/cfssl
cp cfssljson_*_linux_amd64 /usr/local/bin/cfssljson
chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

mkdir /etc/etcd/ssl -p

cat > ca-config.json << EOF 
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "876000h"
      }
    }
  }
}
EOF

cat > etcd-ca-csr.json  << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare /etc/etcd/ssl/etcd-ca
cat > etcd-csr.json << EOF 
{
  "CN": "etcd",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "etcd",
      "OU": "Etcd Security"
    }
  ]
}
EOF

cfssl gencert \
   -ca=/etc/etcd/ssl/etcd-ca.pem \
   -ca-key=/etc/etcd/ssl/etcd-ca-key.pem \
   -config=ca-config.json \
   -hostname=127.0.0.1,0.0.0.0,${master1_hostname},${master1_ip},${master1_hostname}.mydomain.com \
   -profile=kubernetes \
   etcd-csr.json | cfssljson -bare /etc/etcd/ssl/etcd

mkdir -p /etc/kubernetes/pki

cat > ca-csr.json   << EOF 
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ],
  "ca": {
    "expiry": "876000h"
  }
}
EOF
cfssl gencert -initca ca-csr.json | cfssljson -bare /etc/kubernetes/pki/ca
cat > apiserver-csr.json << EOF 
{
  "CN": "kube-apiserver",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "Kubernetes",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF
cfssl gencert   \
-ca=/etc/kubernetes/pki/ca.pem   \
-ca-key=/etc/kubernetes/pki/ca-key.pem   \
-config=ca-config.json   \
-hostname=10.96.0.1,${master1_hostname},${master1_ip},${master1_hostname}.mydomain.com,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local   \
-profile=kubernetes   apiserver-csr.json | cfssljson -bare /etc/kubernetes/pki/apiserver

cat > front-proxy-ca-csr.json  << EOF 
{
  "CN": "kubernetes",
  "key": {
     "algo": "rsa",
     "size": 2048
  },
  "ca": {
    "expiry": "876000h"
  }
}
EOF

cfssl gencert   -initca front-proxy-ca-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-ca 
cat > front-proxy-client-csr.json  << EOF 
{
  "CN": "front-proxy-client",
  "key": {
     "algo": "rsa",
     "size": 2048
  }
}
EOF

cfssl gencert  \
-ca=/etc/kubernetes/pki/front-proxy-ca.pem   \
-ca-key=/etc/kubernetes/pki/front-proxy-ca-key.pem   \
-config=ca-config.json   \
-profile=kubernetes   front-proxy-client-csr.json | cfssljson -bare /etc/kubernetes/pki/front-proxy-client

cat > manager-csr.json << EOF 
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   manager-csr.json | cfssljson -bare /etc/kubernetes/pki/controller-manager

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://${master1_ip}:6443 \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
     --client-certificate=/etc/kubernetes/pki/controller-manager.pem \
     --client-key=/etc/kubernetes/pki/controller-manager-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig
kubectl config use-context system:kube-controller-manager@kubernetes \
     --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig

cat > scheduler-csr.json << EOF 
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   scheduler-csr.json | cfssljson -bare /etc/kubernetes/pki/scheduler

kubectl config set-cluster kubernetes \
     --certificate-authority=/etc/kubernetes/pki/ca.pem \
     --embed-certs=true \
     --server=https://${master1_ip}:6443 \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config set-credentials system:kube-scheduler \
     --client-certificate=/etc/kubernetes/pki/scheduler.pem \
     --client-key=/etc/kubernetes/pki/scheduler-key.pem \
     --embed-certs=true \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config set-context system:kube-scheduler@kubernetes \
     --cluster=kubernetes \
     --user=system:kube-scheduler \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
kubectl config use-context system:kube-scheduler@kubernetes \
     --kubeconfig=/etc/kubernetes/scheduler.kubeconfig
cat > admin-csr.json << EOF 
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:masters",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF
cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   admin-csr.json | cfssljson -bare /etc/kubernetes/pki/admin

kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://${master1_ip}:6443     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-credentials kubernetes-admin  \
  --client-certificate=/etc/kubernetes/pki/admin.pem     \
  --client-key=/etc/kubernetes/pki/admin-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

kubectl config set-context kubernetes-admin@kubernetes    \
  --cluster=kubernetes     \
  --user=kubernetes-admin     \
  --kubeconfig=/etc/kubernetes/admin.kubeconfig

cat > kube-proxy-csr.json  << EOF 
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "system:kube-proxy",
      "OU": "Kubernetes-manual"
    }
  ]
}
EOF

cfssl gencert \
   -ca=/etc/kubernetes/pki/ca.pem \
   -ca-key=/etc/kubernetes/pki/ca-key.pem \
   -config=ca-config.json \
   -profile=kubernetes \
   kube-proxy-csr.json | cfssljson -bare /etc/kubernetes/pki/kube-proxy

kubectl config set-cluster kubernetes     \
  --certificate-authority=/etc/kubernetes/pki/ca.pem     \
  --embed-certs=true     \
  --server=https://${master1_ip}:6443     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy  \
  --client-certificate=/etc/kubernetes/pki/kube-proxy.pem     \
  --client-key=/etc/kubernetes/pki/kube-proxy-key.pem     \
  --embed-certs=true     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config set-context kube-proxy@kubernetes    \
  --cluster=kubernetes     \
  --user=kube-proxy     \
  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

kubectl config use-context kube-proxy@kubernetes  --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig

openssl genrsa -out /etc/kubernetes/pki/sa.key 2048
openssl rsa -in /etc/kubernetes/pki/sa.key -pubout -out /etc/kubernetes/pki/sa.pub

