set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"

cd ../../yaml
# nfs安装
if [[ "$nfs_enabled" == "true "]]
    then 
        helm upgrade --install nfs-subdir-external-provisioner ./nfs-subdir-external-provisioner --namespace=environment --create-namespace \
            --set nfs.server=${nfs_server} \
            --set nfs.path="${nfs_path}" \
            --set storageClass.name=nfs-client
fi

# ingress安装
helm upgrade --install ingress-nginx ./ingress-nginx \
  --set controller.hostNetwork=true \
  --set controller.ingressClass=nginx \
  --set controller.kind=DaemonSet \
  --set controller.service.type=NodePort \
  --set controller.opentelemetry.enabled=true \
  --set controller.metrics.enabled=true \
  --set controller.allowSnippetAnnotations=true

  --namespace environment --create-namespace

#prometheus安装

kubectl apply --server-side -f kube-prometheus/manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f kube-prometheus/manifests/

# redis安装
kubectl apply -f redis.yaml
#kuboard安装
bash   kuboard.sh

#loki安装
kubectl create ns environment
#helm  install grafana yaml/loki/grafana --namespace  environment 
helm  upgrade --install loki ./loki-stack --namespace  environment --create-namespace \
    --set promtail.enabled=false \
    --set loki.service.type=NodePort \
    --set loki.persistence.enabled=true \
    --set loki.persistence.size=10Gi \
    --set loki.persistence.storageClassName=nfs-client
#前端自动重启安装
kubectl apply -f reloader.yaml


#apollo安装
helm upgrade --install --cleanup-on-fail apollo-service-pro \
  --set configdb.host=1.1.1.1 \
  --set configdb.dbName=ApolloConfigDB \
  --set configdb.userName=sa \
  --set configdb.password=123 \
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
  ./apollo-service --create-namespace

# 部署apollo-portal
helm upgrade --install --cleanup-on-fail apollo-portal \
  --set portaldb.host=1.1.1.1 \
  --set portaldb.dbName=ApolloPortalDB \
  --set portaldb.userName=sa \
  --set portaldb.password=123 \
  --set portaldb.port=3306 \
  --set portaldb.service.enabled=true \
  --set config.envs="pro" \
  --set config.metaServers.pro=http://apollo-service-pro-apollo-configservice:30012 \
  --set replicaCount=1 \
  --set service.type=NodePort \
  --set service.nodePort=30011 \
  -n environment \
  ./apollo-portal --create-namespace


Config service: http://apollo-service-pro-apollo-configservice.environment:30012
Admin service: http://apollo-service-pro-apollo-adminservice.environment:8090
Apollo Portal： http://192.168.1.196:30011
用户名：apollo， 密码：admin
