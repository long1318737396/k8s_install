# 基于ansible离线部署

## 需求

需要知道各个服务器节点的账号密码，且需root账户

操作都是在harbor服务器上执行ansible playbook，切勿复用master节点否则会导致任务执行失败

如果操作系统节点内核低于4.19,建议使用calico网络插件

## 已安装好harbor和nfs

[harbor安装](./harbor.md)

[nfs安装](./nfs.md)


## 启动ansible容器

在安装harbor之后，会在harbor服务器上配置下载访问

```bash
#在harbor服务器上确认kubespray和nginx容器启动是否正常
docker-compose ps
```

## 参数配置

- 配置服务器的账户密码，需使用root账户

- 配置相关环境变量

- 确认conf/config.sh配置文件的正确性，因为会拷贝到目标节点上去

```bash
vi inventory/inventory.ini   #确保正确的inventory_hostname脚本会自动设置主机名，inventory_hostname会做为k8s节点注册的名称
vi inventory/group_vars/k8s_cluster.yml
```

## 文件分发


```bash
#确认安装包已拷贝到当前文件夹下
ls -l k8s_install.tar.gz
```

通过ansible将文件分发到各个节点上
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/1.copy-k8s-install.yml
```

## 安装k8s集群

运行时安装
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/2.env.yml
```

初始化第一台master节点
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/3.first-master-install.yml
```

加入其他master节点
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/4.other-master.yml
```

加入node节点
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/5.join-node.yml
```

安装组件
```bash
docker exec kubespray ansible-playbook -i inventory/inventory.ini playbooks/6.addon-install.yml
```