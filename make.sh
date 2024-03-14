#!/bin/bash

# 解析命令行参数
arch=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --arch=*)
            arch="${1#*=}"
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

# 检查是否提供了 --arch 参数
if [ -z "$arch" ]; then
    echo "Please provide --arch parameter."
    exit 1
fi

# 替换 amd64 为指定的 arch 值
binary_script="offline/bin/$arch/download-binary.sh"
image_script="offline/images/$arch/download.sh"
yum_script="offline/yum/$arch/centos8/build.sh"

# 执行脚本
bash "$binary_script"
bash "$image_script"
bash "$yum_script"

mv _output/bin/* "offline/bin/$arch/"
mv _output/images/* "offline/images/$arch/"

cd ../
tar --exclude='k8s_install/.git' -czvf k8s_install.tar.gz k8s_install/
cp k8s_install.tar.gz k8s_install/