## 部署要求
- 操作系统:
  - 建议内核版本>=5.10
  - 内网建议有ntp服务
  - k8s以及nfs节点需要通harbor的443端口拉取镜像
  - k8s以及nfs节点需要通harbor的38088端口拉取离线包
  - 服务器操作需使用root账户

- 服务器:

  建议配置:
  - 1台harbor (**建议可以联网**)
  - 1台nfs
  - 3台master
  - 2台node节点

- 配置要求
  - master: cpu cores >= 4, mem >= 16G, 两块数据盘，一块做为containerd数据盘，另一块做为etcd和集群备份
  - node: cpu cores >= 8, mem >= 32G, 一块数据盘
  - nfs: cpu cores >= 4, mem >= 8G，一块nfs数据盘
  - harbor: cpu cores >= 4, mem >= 8G，一块镜像存储数据盘