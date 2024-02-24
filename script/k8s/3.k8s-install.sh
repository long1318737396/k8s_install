set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh
exec > >(tee -a "$logfile") 2>&1
echo "$date_format"



# 源配置文件
SOURCE_ENV_FILE="../../conf/config.sh"
# 目标配置文件
DEST_FILE="kubeadm-config.yaml"

# 临时创建一个新的 shell 环境来加载和处理环境变量
(
    # 从源配置文件中读取并设置环境变量
    set -a # 自动导出所有后续命令设置的环境变量
    source "$SOURCE_ENV_FILE"
    #!/bin/bash

while IFS='=' read -r key value; do
    # 忽略以井号（#）开头的行以及空行
    if [[ $key =~ ^[[:space:]]*# ]]; then
        continue
    fi

    # 只处理非空且非注释行
    if [[ ! -z "$key" && -z "${key##*[![:space:]]*}" ]]; then
        export "$key=$value"
    fi
done < ../../conf/config.sh
    # 使用 envsubst 替换目标文件中的环境变量
    envsubst < "$DEST_FILE" > "$DEST_FILE.tmp"

    # 如果替换成功且无错误，则覆盖原文件
    if [ $? -eq 0 ]; then
        mv "$DEST_FILE.tmp" "$DEST_FILE"
    fi
)

unset SOURCE_ENV_FILE DEST_FILE


kubeadm init --config=kubeadm-config.yaml --upload-certs
