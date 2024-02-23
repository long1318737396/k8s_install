ctr -a /run/containerd/containerd.sock images ls
ctr images pull docker.io/library/redis:latest --skip-verify
