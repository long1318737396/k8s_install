```bash
# 把配置拷贝到其他 etcd 节点
scp -r /opt/etcd/ root@172.16.16.181:/opt/
scp /usr/lib/systemd/system/etcd.service root@172.16.16.181:/usr/lib/systemd/system/
scp -r /opt/etcd/ root@172.16.16.182:/opt/
scp /usr/lib/systemd/system/etcd.service root@172.16.16.182:/usr/lib/systemd/system/

# 启动 etcd 
systemctl daemon-reload
systemctl start etcd
systemctl enable etcd
```