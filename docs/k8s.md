**网络插件**
- 默认是cilium的native-routing-eBPF-Host-Routing，对于云服务如果不支持则需要[vxlan模式](./cilium_vxlan.md),或者使用calico
- 对于centos7等系统，则必须升级内核版本，否则会导致bpf挂载不上


**集群安装，以下三选一**

如果各个节点没有yum仓库，可以通过有公网的站点拉取rpm包，然后拷贝到目标服务器上进行安装,harbor通外网的话可以通过harbor上拉取

[关于离线rpm包拉取](./rpm_offline.md)

[单master节点集群手动部署](master.md)

[多master高可用集群手动部署](master_ha.md)

[ansible自动化部署](./ansible.md)