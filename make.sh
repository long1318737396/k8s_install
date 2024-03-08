#!/bin/bash
set -x
set -o pipefail
bash offline/bin/amd64/download-binary.sh

bash offline/images/amd64/download.sh

bash offline/yum/amd64/centos8/build.sh

mv _output/bin/* offline/bin/amd64/
mv _output/images/* offline/images/amd64/


cd ../
tar --exclude='k8s_install/.git' -czvf k8s_install.tar.gz k8s_install/
