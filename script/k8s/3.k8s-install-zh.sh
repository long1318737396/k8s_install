set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

# 源配置文件
SOURCE_ENV_FILE="../../conf/config.sh"
# 目标配置文件
DEST_FILE="../../conf/kubeadm-custom-image-zh.yaml"

# 临时创建一个新的 shell 环境来加载和处理环境变量
(
    # 从源配置文件中读取并设置环境变量
    set -a # 自动导出所有后续命令设置的环境变量

    # 将配置文件中的有效变量重新读取并导出到子 shell 中
    while IFS='=' read -r key value; do
        if [[ $key =~ ^[[:space:]]*# ]]; then
            continue
        fi
        if [[ ! -z "$key" && -z "${key##*[![:space:]]*}" ]]; then
            export "$key=$value"
        fi
    done < "$SOURCE_ENV_FILE"

    # 使用 envsubst 替换目标文件中的环境变量
    envsubst < "$DEST_FILE" > "kubeadm-config.yaml"

)

unset SOURCE_ENV_FILE DEST_FILE

mkdir -p /etc/kubernetes/manifests/

if [[ "$kube_vip_enable" == "true" ]]
then
    cat ../../yaml/first-master-kube-vip.yaml \
        | sed -e "s/\${loadbalancer_vip}/${loadbalancer_vip}/g" \
              -e "s/\${kube_vip_eth}/${kube_vip_eth}/g" \
        | tee /etc/kubernetes/manifests/kube-vip.yaml
fi


# 执行 kubeadm init 命令
kubeadm init --config=kubeadm-config.yaml --upload-certs --v=5

if [ $? -ne 0 ]; then
  echo "Command failed. Exiting..."
  exit 1
fi

mkdir -p $HOME/.kube
sudo /bin/cp  /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config