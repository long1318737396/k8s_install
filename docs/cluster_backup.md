## 集群备份

### 条件

- 使用 XFS 格式化

- 为了确保在节点重启后驱动器到挂载点的映射一致，请使用 /etc/fstab 文件

- master节点有另外的数据盘


### 1.安装minio

- 单节单硬盘

配置minio.service
```bash

vi /et/systemd/system/minio.service

[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio
AssertFileNotEmpty=/etc/default/minio

[Service]
Type=notify

WorkingDirectory=/usr/local/

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=1048576

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutSec=infinity

SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
```

如果使用root将上面的user改为root，否则使用普通用户
```bash
groupadd -r minio-user
useradd -M -r -g minio-user minio-user
chown minio-user:minio-user /mnt/disk1 #对应的磁盘
```

创建环境变量文件

```bash
vi /etc/default/minio
```

```bash
#用户名
MINIO_ROOT_USER=minioadmin
#密码
MINIO_ROOT_PASSWORD=minioadmin
#存储位置
MINIO_VOLUMES="/mnt/data"
MINIO_OPTS="--console-address :9001"
#MINIO_SERVER_URL="http://minio.example.net:9000"
```

启动服务

```bash
systemctl enable minio.service
systemctl start minio.service
```

通过在首选的浏览器中输入MinIO服务器 Console控制台 中的任何主机名或IP地址来访问MinIO控制台，例如http://localhost:9001。

-  多节点多硬盘安装

配置minio.service，参考上面配置


环境变量配置
```bash
# MINIO_ROOT_USER and MINIO_ROOT_PASSWORD sets the root account for the MinIO server.
# This user has unrestricted permissions to perform S3 and administrative API operations on any resource in the deployment.
# Omit to use the default values 'minioadmin:minioadmin'.
# MinIO recommends setting non-default values as a best practice, regardless of environment.

MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin

# MINIO_VOLUMES sets the storage volumes or paths to use for the MinIO server.
# The specified path uses MinIO expansion notation to denote a sequential series of drives between 1 and 4, inclusive.
# All drives or paths included in the expanded drive list must exist *and* be empty or freshly formatted for MinIO to start successfully.

MINIO_VOLUMES="https://master{1..3}:9000/mnt/disk/minio"

# MINIO_OPTS sets any additional commandline options to pass to the MinIO server.
# 例如， `--console-address :9001` sets the MinIO Console listen port
MINIO_OPTS="--console-address :9001"

# MINIO_SERVER_URL sets the hostname of the local machine for use with the MinIO Server.
# MinIO assumes your network control plane can correctly resolve this hostname to the local machine.

# Uncomment the following line and replace the value with the correct hostname for the local machine.

#MINIO_SERVER_URL="http://minio.example.net"
```

### 2.配置集群备份

```bash
cat > credentials-velero <<EOF
[default]
aws_access_key_id = minio
aws_secret_access_key = minio123
EOF

velero install \
  --provider aws \
  --image velero/velero:v1.12.3 \
  --plugins velero/velero-plugin-for-aws:v1.6.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-node-agent \
  --use-volume-snapshots=true \
  --namespace velero \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio:9000 \
  --wait
```

一次性备份

```bash
velero backup create default --include-namespaces=environment
velero backup get
velero backup describe default
velero backup logs default
```

定时备份

```bash
# 使用cron表达式备份
velero schedule create nginx-daily --schedule="0 1 * * *" --include-namespaces nginx-example
# 使用一些非标准的速记 cron 表达式
velero schedule create nginx-daily --schedule="@daily" --include-namespaces nginx-example
# 手动触发定时任务
velero backup create --from-schedule nginx-daily
```


恢复

```bash
# 删除nginx-example命名空间和资源
kubectl delete namespace nginx-example
# 检查是否删除
kubectl get all -n nginx-example
No resources found in nginx-example namespace.

$ velero backup get
NAME           STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
nginx-backup   Completed   0        0          2023-03-09 09:38:50 +0800 CST   29d       default            <none>
$ velero restore create --from-backup nginx-backup
Restore request "nginx-backup-20230309095025" submitted successfully.
Run `velero restore describe nginx-backup-20230309095025` or `velero restore logs nginx-backup-20230309095025` for more details.

 velero restore get
 velero restore describe nginx-backup-20230309095025
 kubectl get all -n nginx-example
```

跨集群备份
```bash
集群A
cat > credentials-velero <<EOF
[default]
aws_access_key_id = minio
aws_secret_access_key = minio123
EOF
 
velero install \
  --provider aws \
  --image velero/velero:v1.10.2 \
  --plugins velero/velero-plugin-for-aws:v1.6.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-node-agent \
  --use-volume-snapshots=false \
  --namespace velero \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://192.168.1.103:9000 \
  --wait

集群B
cat > credentials-velero <<EOF
[default]
aws_access_key_id = minio
aws_secret_access_key = minio123
EOF
 
velero install \
  --provider aws \
  --image velero/velero:v1.10.2 \
  --plugins velero/velero-plugin-for-aws:v1.6.0 \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-node-agent \
  --use-volume-snapshots=false \
  --namespace velero \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio:9000 \
  --wait
集群A进行备份  
velero backup create app-backup \
  --default-volumes-to-fs-backup \   #默认将所有PV卷进行备份
  --include-namespaces app-system
Backup request "app-backup" submitted successfully.
Run `velero backup describe app-backup` or `velero backup logs app-backup` for more details.
 
# 查看备份状态
$ velero backup get
NAME         STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
app-backup   Completed   0        0          2023-03-28 16:34:56 +0800 CST   29d       default            <none>

恢复到B集群
# 到集群B中查看备份资源
$ velero backup get
NAME         STATUS      ERRORS   WARNINGS   CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
app-backup   Completed   0        0          2023-03-28 16:41:55 +0800 CST   29d       default            <none>
 
# 执行恢复命令
$ velero restore create --from-backup app-backup
 
# 查看恢复任务
$ velero restore get 
```