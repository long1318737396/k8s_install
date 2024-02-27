#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

ETCDCTL_PATH='/usr/local/bin/etcdctl'
ENDPOINTS='https://127.0.0.1:2379'
ETCD_DATA_DIR="/data/kubernetes/etcd"
BACKUP_DIR="/data/kubernetes_backup_dontdelete/etcd/etcd-$(date +%Y-%m-%d-%H-%M-%S)"
KEEPBACKUPNUMBER='6'
ETCDBACKUPSCIPT='/usr/local/bin/kube-scripts'

ETCDCTL_CERT="/etc/kubernetes/pki/etcd/server.crt"
ETCDCTL_KEY="/etc/kubernetes/pki/etcd/server.key"
ETCDCTL_CA_FILE="/etc/kubernetes/pki/etcd/ca.crt"

[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR

export ETCDCTL_API=2;$ETCDCTL_PATH backup --data-dir $ETCD_DATA_DIR --backup-dir $BACKUP_DIR

sleep 3

{
export ETCDCTL_API=3;$ETCDCTL_PATH --endpoints="$ENDPOINTS" snapshot save $BACKUP_DIR/snapshot.db \
                                   --cacert="$ETCDCTL_CA_FILE" \
                                   --cert="$ETCDCTL_CERT" \
                                   --key="$ETCDCTL_KEY"
} > /dev/null 

sleep 3

cd $BACKUP_DIR/../ && ls -lt |awk '{if(NR > '$KEEPBACKUPNUMBER'){print "rm -rf "$9}}'|sh


