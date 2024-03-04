set -x
dir="$(cd "$(dirname "$0")" && pwd)"
cd $dir
source ../../conf/config.sh

exec > >(tee -a "$logfile") 2>&1
echo "$date_format"



cd ../../yaml

    set -a # 自动导出所有后续命令设置的环境变量

    # 将配置文件中的有效变量重新读取并导出到子 shell 中
    while IFS='=' read -r key value; do
        if [[ $key =~ ^[[:space:]]*# ]]; then
            continue
        fi
        if [[ ! -z "$key" && -z "${key##*[![:space:]]*}" ]]; then
            export "$key=$value"
        fi
    done < "../conf/config.sh"

kubectl create ns environment

#metrics-server安装
kubectl apply -f components.yaml

# gateway api安装
kubectl apply -f experimental-install.yaml

#二层LB安装
kubectl apply -f metallb-native.yaml

# ingress安装
helm upgrade --install ingress-nginx ./ingress-nginx \
  --set controller.hostNetwork=true \
  --set controller.ingressClass=nginx \
  --set controller.kind=DaemonSet \
  --set controller.service.type=NodePort \
  --set controller.opentelemetry.enabled=true \
  --set controller.metrics.enabled=true \
  --set controller.allowSnippetAnnotations=true \
  --namespace environment --create-namespace

# reloader.yaml安装

kubectl apply -f reloader.yaml

# redis安装
kubectl apply -f redis.yaml
#kuboard安装
bash   kuboard.sh

#本地存储安装
kubectl apply -f local-path-storage.yaml


# nfs安装
if [[ "$nfs_enabled" == "true" ]]
    then 
        helm upgrade --install nfs-subdir-external-provisioner ./nfs-subdir-external-provisioner --namespace=environment --create-namespace \
            --set nfs.server=${nfs_server} \
            --set nfs.path="${nfs_path}" \
            --set storageClass.name=nfs-client
fi


#prometheus安装

kubectl apply --server-side -f kube-prometheus/manifests/setup
# kubectl wait \
# 	--for condition=Established \
# 	--all CustomResourceDefinition \
# 	--namespace=monitoring
kubectl apply -f kube-prometheus/manifests/



#loki安装
#helm  install grafana yaml/loki/grafana --namespace  environment 
helm  upgrade --install loki ./loki-stack --namespace  environment --create-namespace \
    --set promtail.enabled=false \
    --set loki.service.type=NodePort \
    --set loki.persistence.enabled=true \
    --set loki.persistence.size=10Gi \
    --set loki.persistence.storageClassName=nfs-client




#apollo安装
helm upgrade --install --cleanup-on-fail apollo-service-pro \
  --set configdb.host=${apollo_db_host} \
  --set configdb.dbName=${apollo_configdb_name} \
  --set configdb.userName=${apollo_db_username} \
  --set configdb.password=${apollo_db_password} \
  --set configdb.service.enabled=true \
  --set configdb.port=${apollo_db_port} \
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
  --set portaldb.host=${apollo_db_host} \
  --set portaldb.dbName=${apollo_portdb_name} \
  --set portaldb.userName=${apollo_db_username} \
  --set portaldb.password=${apollo_db_password} \
  --set portaldb.port=${apollo_db_port} \
  --set portaldb.service.enabled=true \
  --set config.envs="pro" \
  --set config.metaServers.pro=http://apollo-service-pro-apollo-configservice:30012 \
  --set replicaCount=1 \
  --set service.type=NodePort \
  --set service.nodePort=30011 \
  -n environment \
  ./apollo-portal --create-namespace



