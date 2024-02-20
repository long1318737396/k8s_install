kubectl apply -f yaml/standard-install.yaml
cd software/
tar -zxvf helm-v3.13.3-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
chmod +x /usr/local/bin/helm 
helm completion bash > /etc/profile.d/helm.sh
tar -zxvf etcd-v3.5.10-linux-amd64.tar.gz
/bin/cp etcd-v3.5.10-linux-amd64/{etcdutl,etcdctl} /usr/local/bin/
chmod +x /usr/local/bin/{etcdutl,etcdctl}
/bin/cp calicoctl-linux-amd64 /usr/local/bin/calicoctl
cd ../
kubectl apply -f yaml/redis.yaml
kubectl create -f yaml/prometheus/setup/
kubectl create -f yaml/prometheus
bash yaml/kuboard.sh

kubectl create ns environment
#helm  install grafana yaml/loki/grafana --namespace  environment 
helm  install loki yaml/loki/loki-stack --namespace  environment
helm install eg --create-namespace oci://docker.io/envoyproxy/gateway-helm -n envoy-gateway-system --skip-crds --create-namespace

echo  "export PATH=\$PATH:$(pwd)/yaml/istio-1.20.1/bin" >> /etc/profile
istioctl install --set profile=minimal -y

kubectl apply -f yaml/reloader.yaml
cd yaml/kong
kubectl apply -f gateway.yaml
helm install kong  ingress -n kong --create-namespace 
cd ../../
