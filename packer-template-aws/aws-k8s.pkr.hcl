packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  working_dir = "${var.remote_folder}/worker"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "samene-k8s-${var.kubernetes_version}"
  instance_type = "t4g.small"
  region        = "ap-south-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  ami_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "mkdir -p ${local.working_dir}/rootfs"
    ]
  }

  provisioner "file" {
    source      = "./runtime/rootfs/"
    destination = "${local.working_dir}/rootfs"
  }

  provisioner "shell" {
    inline = [
      "sudo cp -rv ${local.working_dir}/rootfs/* /"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "KUBERNETES_VERSION=${var.kubernetes_version}"
    ]
    scripts = [
      "k8s-setup.sh",
    ]
  }

  provisioner "shell" {
    scripts = [
      "cleanup.sh",
    ]
  }
}