## k8s节点配置

bgp配置
```yaml
kubectl get bgpconfigurations.crd.projectcalico.org default -o yaml
apiVersion: crd.projectcalico.org/v1
kind: BGPConfiguration
metadata:
  annotations:
    projectcalico.org/metadata: '{"uid":"c2a6fc6c-8652-4d0f-8a89-44c2ccb2a6a3","creationTimestamp":"2023-08-07T14:58:03Z"}'
  creationTimestamp: "2023-08-07T14:58:03Z"
  generation: 5
  name: default
  resourceVersion: "16141123"
  uid: 95d94ee2-9397-4ffc-b771-c9a029854f3c
spec:
  asNumber: 64512
  bindMode: NodeIP
  listenPort: 179
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: false
  prefixAdvertisements:
  - cidr: 10.244.0.0/16
  serviceClusterIPs:
  - cidr: 10.233.0.0/18
```

BGP邻居
```yaml
kubectl get bgppeers.crd.projectcalico.org peer-with-route-reflectors -o yaml
apiVersion: crd.projectcalico.org/v1
kind: BGPPeer
metadata:
  annotations:
    projectcalico.org/metadata: '{"uid":"536ce3d7-0252-4be2-8405-b023e4080c7a","creationTimestamp":"2023-09-21T08:58:28Z"}'
  creationTimestamp: "2023-09-21T08:58:28Z"
  generation: 2
  name: peer-with-route-reflectors
  resourceVersion: "16142062"
  uid: d9b4975a-630a-4a7c-b108-a24597aca58c
spec:
  asNumber: 64513
  keepOriginalNextHop: true
  peerIP: 192.168.1.107
```

BGP路由配置

以下是vyos配置
```bash
show  configuration commands 
set interfaces ethernet eth0 address '192.168.1.107/24'
set interfaces ethernet eth0 hw-id '00:0c:29:b4:c5:bd'
set interfaces ethernet eth1 hw-id '00:0c:29:b4:c5:c7'
set interfaces loopback lo address '172.18.8.8/32'
set protocols bgp 64513 address-family ipv4-unicast redistribute connected
set protocols bgp 64513 neighbor 192.168.1.113 address-family ipv4-unicast as-override
set protocols bgp 64513 neighbor 192.168.1.113 remote-as '64512'
set protocols bgp 64513 neighbor 192.168.1.114 address-family ipv4-unicast as-override
set protocols bgp 64513 neighbor 192.168.1.114 remote-as '64512'
set protocols bgp 64513 neighbor 192.168.1.115 address-family ipv4-unicast as-override
set protocols bgp 64513 neighbor 192.168.1.115 remote-as '64512'
set protocols bgp 64513 neighbor 192.168.1.116 address-family ipv4-unicast as-override
set protocols bgp 64513 neighbor 192.168.1.116 remote-as '64512'
set protocols static route 0.0.0.0/0 next-hop 192.168.1.254
set service ssh listen-address '192.168.1.107'
set service ssh port '22'
set system config-management commit-revisions '100'
set system console device ttyS0 speed '9600'
set system host-name 'vyos'
set system login user vyos authentication encrypted-password '$6$MjV2YvKQ56q$QbL562qhRoyUu8OaqrXagicvcsNpF1HssCY06ZxxghDJkBCfSfTE/4FlFB41xZcd/HqYyVBuRt8Zyq3ozJ0dc.'
set system login user vyos authentication plaintext-password ''
set system login user vyos level 'admin'
set system name-server '114.114.114.114'
set system ntp server time1.vyos.net
set system ntp server time2.vyos.net
set system ntp server time3.vyos.net
set system syslog global facility all level 'notice'
set system syslog global facility protocols level 'debug'
```

节点确认路由学习情况
```bash
ip route
```