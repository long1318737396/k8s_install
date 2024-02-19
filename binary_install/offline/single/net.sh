source config.cfg
cd ${download_dir}
helm repo add cilium https://helm.cilium.io
tar xvf helm-*-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/

