#!/bin/bash

# Clean up yum caches to reduce the image size
sudo sudo apt-get clean
sudo rm -rf /var/cache/apt

# Clean up files to reduce confusion during debug
sudo rm -rf \
  /tmp/rootfs \
  /tmp/etcd-v3.5.13-linux-arm64 \
  /tmp/etcd.tar.gz \
  /tmp/cni-plugins.tgz \
  /tmp/kubernetes \
  /tmp/kubernetes-server.tar.gz \
  /etc/machine-id \
  /var/log/cloud-init-output.log \
  /var/log/cloud-init.log \
  /var/log/secure \
  /var/log/wtmp \
  /var/log/messages \
  /var/log/audit/*

sudo touch /etc/machine-id