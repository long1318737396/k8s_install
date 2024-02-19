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
#apollo安装
helm upgrade --install --cleanup-on-fail apollo-service-pro \
  --set configdb.host=192.168.1.46 \
  --set configdb.dbName=ApolloConfigDB \
  --set configdb.userName=sa \
  --set configdb.password=tomtaw \
  --set configdb.service.enabled=true \
  --set configdb.port=3306 \
  --set configService.replicaCount=1 \
  --set adminService.replicaCount=1 \
  --set configService.containerPort=8080 \
  --set configService.service.type=NodePort \
  --set configService.service.port=30012 \
  --set configService.service.targetPort=8080 \
  --set configService.service.nodePort=30012 \
  -n environment \
  ./apollo-service

# 部署apollo-portal
helm upgrade --install --cleanup-on-fail apollo-portal \
  --set portaldb.host=192.168.1.46 \
  --set portaldb.dbName=ApolloPortalDB \
  --set portaldb.userName=sa \
  --set portaldb.password=tomtaw \
  --set portaldb.port=3306 \
  --set portaldb.service.enabled=true \
  --set config.envs="pro" \
  --set config.metaServers.pro=http://apollo-service-pro-apollo-configservice:30012 \
  --set replicaCount=1 \
  --set service.type=NodePort \
  --set service.nodePort=30011 \
  -n environment \
  ./apollo-portal


Config service: http://apollo-service-pro-apollo-configservice.environment:30012
Admin service: http://apollo-service-pro-apollo-adminservice.environment:8090
Apollo Portal： http://192.168.1.196:30011
用户名：apollo， 密码：admin
```