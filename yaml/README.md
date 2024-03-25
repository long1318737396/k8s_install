
```bash
helm upgrade --install openebs --namespace openebs openebs/openebs --set cstor.enabled=true --create-namespace
```

```bash
#helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.0.0 -n envoy-gateway-system --create-namespace --set deployment.replicas=2

helm install eg ./gateway-helm --version v1.0.0 -n envoy-gateway-system --create-namespace --set deployment.replicas=1 \
  --set deployment.envoyGateway.imagePullPolicy=IfNotPresent \
  --set kubernetesClusterDomain=cluster.local
```