假设只有harbor可以通外网，harbor做为ntp服务器，其他节点通过harbor同步时间

harbor配置
```bash
# 服务端
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool ntp.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.1.0/24
local stratum 10
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd
```

其他服务器配置
```bash
# apt install chrony -y
yum install chrony -y
cat > /etc/chrony.conf << EOF 
pool 192.168.1.31 iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF

systemctl restart chronyd ; systemctl enable chronyd

#使用客户端进行验证
chronyc sources -v
```
```text
# 参数解释
#
# pool ntp.aliyun.com iburst
# 指定使用ntp.aliyun.com作为时间服务器池，iburst选项表示在初始同步时会发送多个请求以加快同步速度。
# 
# driftfile /var/lib/chrony/drift
# 指定用于保存时钟漂移信息的文件路径。
# 
# makestep 1.0 3
# 设置当系统时间与服务器时间偏差大于1秒时，会以1秒的步长进行调整。如果偏差超过3秒，则立即进行时间调整。
# 
# rtcsync
# 启用硬件时钟同步功能，可以提高时钟的准确性。
# 
# allow 192.168.0.0/24
# 允许192.168.0.0/24网段范围内的主机与chrony进行时间同步。
# 
# local stratum 10
# 将本地时钟设为stratum 10，stratum值表示时钟的准确度，值越小表示准确度越高。
# 
# keyfile /etc/chrony.keys
# 指定使用的密钥文件路径，用于对时间同步进行身份验证。
# 
# leapsectz right/UTC
# 指定时区为UTC。
# 
# logdir /var/log/chrony
# 指定日志文件存放目录。
```