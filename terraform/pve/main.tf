terraform {
    required_providers {
      proxmox = {
        source = "bpg/proxmox"
        version = "0.72.0"
      }
    }
    backend "s3" {
        bucket = "tfstate.billv.ca"
        key = "pve/terraform.tfstate"
        region = "us-east-1"
    }
}

provider "proxmox" {
  endpoint = var.proxmox_url
  username = var.proxmox_user
  password = var.proxmox_password

  ssh {
    agent = true
    username = "root"

    dynamic "node" {
        for_each = local.nodes
        content {
            name = node.key
            address = node.value
        }
    }
  }
}

resource "random_password" "k3s_secret" {
  length = 40
  special = false
}

locals {
    nodes = {
        node-0 = "10.206.0.2"
        node-1 = "10.206.0.3"
        node-2 = "10.206.0.4"
    }
    additional_k3s_flags = "--disable=servicelb --kubelet-arg=allowed-unsafe-sysctls=net.ipv4.conf.all.src_valid_mark"
    k3s_commands = {
        server = "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_secret.result} sh -s - server --tls-san=${local.k3s_lb_ip} ${local.additional_k3s_flags}"
        agent = "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_secret.result} sh -s - agent --server https://${local.k3s_lb_ip}:6443 ${local.additional_k3s_flags}"
        creator = "curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_secret.result} sh -s - server --cluster-init --tls-san=${local.k3s_lb_ip} ${local.additional_k3s_flags}"
    }
    k3s_lb_ip = "10.206.1.3"
    k3s_vms = {
        k3s-4 = {
            id = 204
            tags = ["kubernetes-agent"]
            role = "agent"
            node = "node-0"
            cpus = 1
            memory = 2048
        }
        k3s-3 = {
            id = 201
            tags = ["kubernetes-server","kubernetes-cluster-init"]
            role = "creator"
            cpus = 1
            node = "node-1"
            memory = 2048
        }
        # {
        #     name = "k3s-1"
        #     id = 202
        #     tags = ["kubernetes-server"]
        #     node = "node-1"
        #     cpus = 1
        #     memory = 512
        # },
        # {
        #     name = "k3s-2"
        #     id = 203
        #     tags = ["kubernets-server"]
        #     node = "node-2"
        #     cpus = 1
        #     memory = 512
        # }
    }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = local.k3s_vms
  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.value.node

  source_raw {
    data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        ubuntu:example
      expire: false
    hostname: ${each.key}
    packages:
      - qemu-guest-agent
      - unattended-upgrades
    users:
      - default
      - name: ubuntu
        groups: sudo
        shell: /bin/bash
        ssh-authorized-keys:
          - ${trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
     - ['/bin/sh', '-c', '${lookup(local.k3s_commands, each.value.role)}']
    EOF

    file_name = "${each.key}.cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24_noble_qcow2_img" {
  for_each = local.nodes
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}



resource "random_password" "ubuntu_vm_password" {
 length           = 16
 override_special = "_%@"
 special          = true
}

resource "tls_private_key" "ubuntu_vm_key" {
 algorithm = "RSA"
 rsa_bits  = 2048
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = local.k3s_vms
  #count = length(local.k3s_vms)
  name = each.key
  description = "K3S VM managed by terraform"
  tags = each.value.tags
  node_name = each.value.node
  vm_id = each.value.id

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  cpu {
    cores        = each.value.cpus
    type         = "host"  # recommended for modern CPUs
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.latest_ubuntu_24_noble_qcow2_img[each.value.node].id
    interface    = "scsi0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.ubuntu_vm_key.public_key_openssh)]
      password = random_password.ubuntu_vm_password.result
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    version = "v2.0"
  }

  serial_device {}
}
