# Kubernetes installer - the "hard way"

Ansible scripts to install Kubernetes the "hard way" inspired from [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

## Step 1

Create a folder to save your inventory file and SSH key.
```
mkdir -p ~/k8s-installer
```

Copy the SSH private key that will be used to connect to the cluster nodes in this folder. For example:
```
cp ~/.ssh/id_rsa ~/k8s-installer/
```

## Step 2

Start the docker container in this folder
```
cd ~/k8s-installer
docker run -it --name k8s-installer \
  -v ${PWD}:/root/k8s_installer/vars docker.io/samene/k8s-installer:main
```

## Step 3

Create an inventory file in `./vars/inventory.ini` with the cluster configuration. Sample inventory provided in `./sample_inventory`

```
node1 ansible_host=10.151.0.13  internal_ip=10.151.0.13
node2 ansible_host=10.151.0.11  internal_ip=10.151.0.11
node3 ansible_host=10.151.0.12  internal_ip=10.151.0.12
node4 ansible_host=10.151.0.10  internal_ip=10.151.0.10
node5 ansible_host=10.151.0.14  internal_ip=10.151.0.14

[etcd]
node1

[control_plane]
node1

[worker]
node1
node2
node3
node4
node5

[all:vars]
ansible_python_interpreter=auto_silent
ansible_ssh_user=cloud-user
ansible_ssh_private_key_file="./vars/id_rsa"
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=120s'
```

## Step 4

Create a file `./vars/vars.yaml` containing the versions and configuration of different components. Sample file provided in `./sample_inventory`

```
######################
# component versions
######################
etcd_version: 3.6.2
kubernetes_version: 1.33.3
containerd_version: 2.1.3
runc_version: 1.3.0
cni_version: 1.7.1
flanneld_version: 0.27.0
flannel_version: 1.7.1-flannel1
canal_version: 3.30.0
k9s_version: 0.50.9
helmfile_version: 1.1.0
local_path_provisioner_version: 0.0.31
coredns_version: 1.43.0
######################
# environment
######################
http_proxy:
https_proxy:
no_proxy:
######################
# configuration
######################
security_hardening: false
cni: canal
insecure_registries:
  - 'http://10.151.0.6:5000'
  - 'https://10.4.5.6:8543'
######################
# features
######################
longhorn_enabled: false
prometheus_enabled: false
cert_manager_enabled: false
ingress_nginx_enabled: false
rancher_enabled: false
```

## Step 5

Run the playbook.

```
ansible-playbook -i vars/inventory.ini create_cluster.yml -e "@vars/vars.yaml"
```

## Access the cluster

SSH to the control plane node and run `kubectl` commands or access using `k9s`

## Pre-requisites for cluster creation
1. Internet access on all nodes
2. `x86_64` or `aarch64` based system architecture
3. Control plane and Worker nodes: Min 2vCPU | 4Gi Memory | 20Gi disk
4. Any Debian or RedHat based OS - Ubuntu, CentOS, Rocky etc.

