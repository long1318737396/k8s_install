
## etcd备份

根据现场环境，确认资源是否充足，选择是否开启etcd的备份，脚本会清理7次之前的备份

确认etcd的备份目录BACKUP_DIR
```bash
vi script/k8s/etcd/etcd_backup.sh
```

执行定时备份
```bash
bash etcd_backup.sh
```