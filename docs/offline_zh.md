## 离线包制作可以通过jenkins去构建或者通过脚本去构建

需求:

需要先安装好docker

- 通过脚本打包

```bash
#海外机器
bash make.sh

#国内机器
# bash make-zh.sh
```

## 100年证书制作

```bash
mkdir code/src/k8s.io -p && cd code/src/k8s.io
version=1.29.2
wget https://github.com/kubernetes/kubernetes/archive/refs/tags/v${version}.tar.gz
tar -zxvf v${version}.tar.gz
mv kubernetes-${version} kubernetes
cd kubernetes
vi staging/src/k8s.io/client-go/util/cert/cert.go 
vi cmd/kubeadm/app/constants/constants.go
yum install gcc make -y
cat ./build/build-image/cross/VERSION
wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.4.linux-amd64.tar.gz
vi / etc/profile
export PATH=$PATH:/usr/local/go/bin
source / etc/profile
# 编译 kubeadm, 这里主要编译 kubeadm 即可
KUBE_BUILD_PLATFORMS=linux/arm64 make all WHAT=cmd/kubeadm GOFLAGS=-v
KUBE_BUILD_PLATFORMS=linux/amd64 make all WHAT=cmd/kubeadm GOFLAGS=-v
```