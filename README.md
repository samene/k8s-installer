# Kubernetes installer - the "hard way"

Ansible scripts to install Kubernetes the "hard way" inspired from [https://github.com/kelseyhightower/kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

## Step 1

Create an inventory file `inventory.ini` with the cluster configuration. For example:

```
[etcd]
10.0.0.3   internal_ip=10.0.0.3

[control_plane]
10.0.0.3   internal_ip=10.0.0.3

[worker]
10.0.0.4   internal_ip=10.0.0.4
10.0.0.5   internal_ip=10.0.0.5
10.0.0.6   internal_ip=10.0.0.6
10.0.0.7   internal_ip=10.0.0.7
10.0.0.8   internal_ip=10.0.0.8

[all:vars]
ansible_python_interpreter=auto_silent
ansible_ssh_user=root
ansible_ssh_private_key_file="~/.ssh/id_ed25519"
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=120s'
```

## Step 2

Create a file `vars.yaml` containing the versions of different components. Sample files provided.

```
etcd_version: 3.5.21
kubernetes_version: 1.33.0
containerd_version: 2.1.0
runc_version: 1.3.0
cni_version: 1.7.1
flanneld_version: 0.26.7
flannel_version: 1.6.2-flannel1
k9s_version: 0.50.5
helmfile_version: 0.171.0
local_path_provisioner_version: 0.0.31
coredns_version: 1.42.1

cni: flannel
```

## Step 3

Run the playbook.

```
ansible-playbook -i inventory.ini create_cluster.yml -e "@vars.yaml"
```

## Access the cluster

SSH to the control plane node and run `kubectl` commands or access using `k9s`

## Pre-requisites for cluster creation
1. Internet access on all nodes
2. `x86_64` or `aarch64` based system architecture
3. Control plane and Worker nodes: Min 2vCPU | 4Gi Memory | 20Gi disk
4. Any Debian or RedHat based OS - Ubuntu, CentOS, Rocky etc.



