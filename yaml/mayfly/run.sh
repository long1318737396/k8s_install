#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 切换到脚本所在目录
cd "$SCRIPT_DIR"

mkdir -p /opt/sql
/bin/cp mayfly-go.sqllite /opt/sql/mayfly-go.sqllite

kubectl apply -f mayfly-configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
