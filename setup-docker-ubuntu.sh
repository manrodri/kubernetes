#!/bin/bash
# script that runs 
# https://kubernetes.io/docs/setup/production-environment/container-runtime


sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update

sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


# notice that only verified versions of Docker may be installed
# verify the documentation to check if a more recent version is available

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

[ ! -d /etc/docker ] && mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# edit /etc/hosts according your local network
cat >> /etc/hosts << EOF
{
  10.154.0.2 k8s-master-1.example.com k8s-master-1
  10.154.0.3 k8s-worker-1.example.com k8s-worker-1
  10.154.0.4 k8s-worker-2.example.com k8s-worker-2
  10.154.0.5 k8s-worker-3.example.com k8s-worker-3
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker


ufw disable
