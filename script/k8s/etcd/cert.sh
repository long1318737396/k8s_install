set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"


source config.sh

cd ../../../offline/bin/$arch/

chmod +x {cfssljson_${cfssl_version}_linux_${arch},cfssl_${cfssl_version}_linux_${arch},cfssl-certinfo_${cfssl_version}_linux_${arch}}

/bin/cp cfssljson_${cfssl_version}_linux_${arch} /usr/local/bin/cfssljson
/bin/cp  cfssl_${cfssl_version}_linux_${arch} /usr/local/bin/cfssl
/bin/cp  cfssl-certinfo_${cfssl_version}_linux_${arch} /usr/local/bin/cfssl-certinfo

mkdir -p ${etcd_ssldir}/ssl
cd ${etcd_ssldir}/ssl
#cfssl print-defaults config > ca-config.json
#cfssl print-defaults csr > ca-csr.json
cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "876000h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF
# ca-config.json：可以定义多个 profiles，分别指定不同的过期时间、使用场景等参数；后续在签名证书时使用某个 profile；
# signing：表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE；
# server auth：表示client可以用该 CA 对server提供的证书进行验证；
# client auth：表示server可以用该CA对client提供的证书进行验证；
cat > etcd-ca-csr.json << EOF
{
    "CN": "etcd",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "Kubernetes",
            "OU": "System"
        }
    ],
    "ca": {
    "expiry": "876000h"
  }
}
EOF
# CN：Common Name，etcd 从证书中提取该字段作为请求的用户名 (User Name)；浏览器使用该字段验证网站是否合法；
# O：Organization，etcd 从证书中提取该字段作为请求用户所属的组 (Group)；
# 这两个参数在后面的kubernetes启用RBAC模式中很重要，因为需要设置kubelet、admin等角色权限，那么在配置证书的时候就必须配置对了。
cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca -
openssl x509 -in etcd-ca.pem --noout --text
cat > etcd-server-csr.json << EOF
{
    "CN": "etcd",
    "hosts": [
    "${etcd1_ip}",
    "${etcd2_ip}",
    "${etcd3_ip}",
    "127.0.0.1",
    "etcd1.kubernetes.cluster.io",
    "etcd2.kubernetes.cluster.io",
    "etcd3.kubernetes.cluster.io",
    "lb.kubernetes.cluster.io",
    "0.0.0.0"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "BeiJing",
            "ST": "BeiJing"
        }
    ]
}
EOF
cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -profile=kubernetes etcd-server-csr.json | cfssljson -bare etcd-server
openssl x509 -in etcd-server.pem --noout --text