**网络插件**
- 默认是cilium的native-routing-eBPF-Host-Routing，对于云服务如果不支持则需要[vxlan模式](./cilium_vxlan.md),或者使用calico
- 对于centos7等系统，则必须升级内核版本，否则会导致bpf挂载不上

- 脚本安装会关闭掉防火墙，如需开放端口，请参考[端口开放](./port.md)

**集群安装，以下三选一**

如果各个节点没有yum仓库，可以通过有公网的站点harbor拉取[rpm包](./rpm_offline.md)，然后拷贝到目标服务器上进行安装,或者本地挂载 full iso镜像，然后进行yum安装。


查看k8s必须要有的rpm依赖包,否则会导致k8s集群初始化失败，建议提取安装

```bash
cat 1.yum_install_online.sh
```



[单master节点集群手动部署](master.md)

[多master高可用集群手动部署](master_ha.md)

[ansible自动化部署](./ansible.md)

[无vip的配置说明](./k8s_no_vip.md)