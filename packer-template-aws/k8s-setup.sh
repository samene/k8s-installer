#!/bin/bash

set -x
set -eo pipefail

echo "Disable swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Install packages"
sudo apt-get update -y && \
sudo apt-get install -y curl apt-transport-https ca-certificates gpg xz-utils wget

echo "Install containerd"
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd && \
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

echo "Installing etcd binaries"
sudo curl -Lfo /tmp/etcd.tar.gz  https://github.com/etcd-io/etcd/releases/download/v3.5.13/etcd-v3.5.13-linux-arm64.tar.gz
sudo tar -zxf /tmp/etcd.tar.gz -C /tmp
sudo mv /tmp/etcd-v3.5.13-linux-arm64/etcd /usr/local/bin/
sudo mv /tmp/etcd-v3.5.13-linux-arm64/etcdctl /usr/local/bin/
sudo chmod 755 /usr/local/bin/etcd*

echo "Install kubernetes binaries"
sudo curl -Lfo /tmp/kubernetes-server.tar.gz 'https://k8sbinaries.s3.ap-south-1.amazonaws.com/v1.30.0/kubernetes-server-linux-arm64.tar.gz?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjENb%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiEAyu29k3QgDqJ%2BNvb9RfRaCXUVZVdx2coqs0bUmoIwGwYCIGtai%2BFWTRJc%2BONEih3zckG0vlbSnROhTLxzsoJeSeo1KuQCCD8QBBoMNzc3NDQ2MjE5MTA2IgwVyDLYsUHjbjvqkK8qwQLbRY52yLqdCwvmy3%2B2yMWn6lBCDQMXNuh3RtnNtCWg2EE9BuIf%2BjPQVoYMzESbQosjLX0Gb6%2Bu3mJGiRerPcVXTRgt0zujEigzaVIl2Kyq0EHO9C3t4BNiTmAQMXbKYu%2B5OatTEuXO5baX9t%2FIBxo0QqWhUqhwzMH5UzXDqd2%2Bj%2Bt7iz9VHQJ9lzxFSi%2F0E8Jh3SlIFe1hYOJgMQS6AsjdNilvVsP3QbJ6ijQ55iF9ZBuWsS1vcXe1tSZxpeVd6J4Ym28GeB27h9eYaz94jRWGHvX0VnhlR1A0Qf9jZdRMZrPRleVgTc%2FaiTHWp14sP4X7rvg5%2Bv3rEG%2FONUjMN8Rug1GhN0BpgKxfBBV1ydaYTuP3BiFJ5nDKVWUluoLYzumGkDegUBqtp3jKtSsI8x197MtgVC6TGbJBs1uP%2FCkEsdcwg4f8sQY6swKPyl%2Bv0aI5fdQSb8%2FrpGZcgspJLY6mwCxSsikuqVvMKah%2Btl7vjWZ%2F6PqyFAaH5VBSRthBcY%2F3l3r8jY7xeh%2FgGBZnAV6%2FQkGmcjc%2BfxGUUEovtJFR8CyE%2FfbuFNpjVbQP8ky%2FwAwvAunJ08O1wPMzrx7u3KOZx4MHLX7boQhG%2FYyCcSwg6bzSzyrhnFJP06gpPzDHI2YyPq6pUJ7P0n8%2Fqx3rcaBPkhAcLPyR8Um71snGkn%2Fner0wbD7BUAU1Y7%2BWe290iVut9jREQen3Gur6L13gjgt8j%2BArlN9pbe%2F7pPiONjjecvESS2H7DXn33JQeTu77freBvW4zh%2FLIKFclzxANH0lTgNs5VXycZ%2BFM2pwQid7NMTBqs7mLfdqmUW2Rpi8Lncyllk3Ax24F84ndHWBS&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20240511T053614Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIA3KA3H3VRGNRSC7UW%2F20240511%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=2604e053c853a0e3fcf52cf676c3335e1ef7e8f85f4b3e80657af8cce85117b0'
sudo tar -zxf /tmp/kubernetes-server.tar.gz -C /tmp
sudo mv /tmp/kubernetes/server/bin/kube-apiserver /usr/local/bin/
sudo mv /tmp/kubernetes/server/bin/kube-controller-manager /usr/local/bin/
sudo mv /tmp/kubernetes/server/bin/kube-scheduler /usr/local/bin/
sudo mv /tmp/kubernetes/server/bin/kubectl /usr/local/bin/
sudo mv /tmp/kubernetes/server/bin/kubelet /usr/local/bin/
sudo mv /tmp/kubernetes/server/bin/kube-proxy /usr/local/bin/
sudo chmod 700 /usr/local/bin/kube*
sudo chmod 755 /usr/local/bin/kubectl

echo "Installing CNI"
sudo curl -Lfo /tmp/cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v1.4.1/cni-plugins-linux-arm64-v1.4.1.tgz
sudo mkdir -p /opt/cni/bin
sudo chmod 700 /opt/cni/bin
sudo tar -zxf /tmp/cni-plugins.tgz -C /opt/cni/bin

echo "Install helm"
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash

echo "Install helmfile"
sudo curl -Lf https://github.com/helmfile/helmfile/releases/download/v0.162.0/helmfile_0.162.0_linux_arm64.tar.gz -o helmfile.tar.gz && \
sudo tar -xvf helmfile.tar.gz && \
sudo chmod +x helmfile && \
sudo mv helmfile /usr/local/bin/helmfile && \
sudo rm helmfile.tar.gz