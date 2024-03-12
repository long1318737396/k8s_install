```bash
#清除containerd的安装和k8s
#会执行kubeadm reset --force
ansible-playbook  -i inventory/cluster/inventory.ini playbooks/clean-containerd.yml
#清除etcd的安装
ansible-playbook  -i inventory/cluster/inventory.ini playbooks/clean-etcd.yml
```