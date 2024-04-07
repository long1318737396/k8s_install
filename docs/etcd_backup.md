
## etcd备份

确认etcd的备份目录BACKUP_DIR
```bash
vi script/k8s/etcd/etcd_backup.sh
```

执行定时备份
```bash
bash etcd_backup.sh
```