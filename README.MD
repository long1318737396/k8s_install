```bash
# 创建一个名为 dev-harbor-secret 的 Docker 仓库凭证。
kubectl create ns eworldcloud
kubectl create secret docker-registry dev-harbor-secret \
  --docker-server=harbor.mtywcloud.com \
  --docker-username=admin \
  --docker-password=Tomtaw@2023 \
  --docker-email=panggle@mtywcloud.com -n eworldcloud
# <your-registry-server> 是你的私有 Docker 仓库全限定域名（FQDN）。 DockerHub 使用 https://index.docker.io/v1/。
```

```bash
# 创建一个名为 eworldcloud-ingress-secret 的 TLS 证书。
kubectl create secret tls eworldcloud-ingress-secret \
    --namespace eworldcloud \
    --key server.key \
    --cert server.crt
```

```bash
#安装 eworldcloud-cm-ingress 服务
#cd yaml/eworldcloud/eworld_ingress
helm install eworld-ingress  . --namespace eworldcloud --create-namespace 
```
```bash
# 前端安装
#cd yaml/eworldcloud/eworld_frontend

helm  install epis-frontend .  -n eworldcloud --create-namespace \
  --set image.tag=v1.0.20 \
  --set image.repository=harbor.mtywcloud.com/publish
```
```bash

```