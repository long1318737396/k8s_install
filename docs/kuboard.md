## kuboard可视化配置

登录kuboard

打开浏览器使用master1节点ip+32766登录 kuboard web页面,[查看kuboard默认密码](./admin.md)

              
```mermaid
graph LR
A[登录kuboard] -->B(输入名称)
    A -->C(输入描述)
    A -->D(选择KubeConfig)
    D -->E(贴入master节点的kubeconfig)
```
![kuboard](./images/kuboard1.png)

kubeconfig可以在任意master节点的cat ~/.kube/config中查看

![kuboard](./images/kuboard2.png)

然后点击确定

![kuboard](./images/kuboard3.png)

选择管理员身份，点击集群概要

![kuboard](./images/kuboard4.png)

然后查看具体的命名空间，进行操作

![kuboard](./images/kuboard5.png)

![kuboard](./images/kuboard6.png)