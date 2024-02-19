source config.cfg
if [ runtime = "docker" ];
  then
    bash runtime/docker.sh
  elif [ runtime = "crio" ];
  then
    bash runtime/crio.sh
  elif  [ runtime = "containerd" ];
  then
    bash runtime/containerd.sh
  else
    echo "runtime is not supported"
    exit 1
  fi
fi
