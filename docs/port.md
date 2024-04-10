## 端口占用

**Note:** 搭建集群时脚本会关闭节点上防火墙，集群搭建完毕后会使用到如下表列出的端口：

| **离线安装时节点** |      |             |                              |                     |
| ---------------------------- | ---- | ----------- | ---------------------------- | ------------------- |
| TCP                          | 入站 | 38088        | registry                     | 节点访问harbor           |
| TCP                          | 入站 | 443       | registry                     | 节点访问harbor           |
| UDP                          | 入站 | 123       | registry                     | 节点访问harbor NTP          |
| **控制平面节点**             |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| TCP                          | 入站 | 6443        | Kubernetes APIserver         | All                 |
| TCP                          | 入站 | 2379-2380   | etcd server clientAPI        | kube-apiserver,etcd |
| TCP                          | 入站 | 10248,10250 | Kubelet API                  | Self,Controlplane   |
| TCP                          | 入站 | 10251,10259 | kube-scheduler               | Self                |
| TCP                          | 入站 | 10252,10257 | kube-controller-manager      | Self                |
| **工作节点**                 |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 80          | ingress-controller           | All                 |
| tcp                          | 入站 | 443         | ingress-controller           | All                 |
| tcp                          | 入站 | 18443       | ingress-controller           | Self                |
| tcp                          | 入站 | 10254       | ingress-controller           | Self                |
| TCP                          | 入站 | 10248,10250 | KubeletAPI                   | Self,Controlplane   |
| TCP                          | 入站 | 30000-32767 | NodePort Services            | All                 |
| TCP                          | 入站 | 10256       | kube-proxy                   | 健康检查            |
| **Flannel**                  |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| UDP                          | 双向 | 8285        | flannel networking(UDP)      | 收发封装数据包      |
| UDP                          | 双向 | 8472        | flannel networking(VXLAN)    | 收发封装数据包      |
| **Calico**                   |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| TCP                          | 双向 | 179         | Calico networking(BGP)       | 收发封装数据包      |
| TCP                          | 双向 | 5473        | Calico networking with Typha | 收发封装数据包      |
| **load-balancer**            |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 2112         | kube-vip                   | lb kube-apiserver   |
| **cilium**            |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 9234         | cilium                  | operator   |
| tcp                          | 入站 | 9891        | cilium                  | operator   |
| tcp                          | 入站 | 9963         | cilium                  | operator   |
| tcp                          | 入站 | 4240         | cilium                  | agent   |
| tcp                          | 入站 | 43215         | cilium                  | agent   |
| tcp                          | 入站 | 6060         | cilium                  | agent   |
| tcp                          | 入站 | 9879         | cilium                  | agent   |
| tcp                          | 入站 | 9890         | cilium                  | agent   |
| tcp                          | 入站 | 9962         | cilium                  | agent   |
| tcp                          | 入站 | 9965         | cilium                  | agent   |
| tcp                          | 入站 | 4244         | cilium                  | agent   |
| **kuboard**            |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 32766         | kuboard                   | web   |
| **grafana**            |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 32765         | grafana                   | web   |
| **redis**            |      |             |                              |                     |
| 协议                         | 方向 | 端口范围    | 使用者                       | 用途                |
| tcp                          | 入站 | 32379         | redis                  | redis   |