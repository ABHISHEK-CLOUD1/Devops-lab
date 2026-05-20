terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.46.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.155.128:8006/"
  api_token = "root@pam!terraform=bff2d81c-dce2-4fe5-ad89-66800425ec59"
  insecure  = true
}

resource "proxmox_virtual_environment_container" "test_container" {
  node_name = "abhi"
  vm_id     = 101
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "terraform-test"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 1 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "jenkins" {
  node_name = "abhi"
  vm_id     = 102
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "jenkins"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 2 }
  memory { dedicated = 1024 }
  disk {
    datastore_id = "local-lvm"
    size         = 10
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "staging" {
  node_name = "abhi"
  vm_id     = 103
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "staging"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 1 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "production" {
  node_name = "abhi"
  vm_id     = 104
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "production"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 1 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "samba_dc" {
  node_name = "abhi"
  vm_id     = 105
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "samba-dc"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 1 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 10
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "prometheus" {
  node_name = "abhi"
  vm_id     = 106
  lifecycle { ignore_changes = all }
  initialization {
    hostname = "prometheus"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 1 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}

resource "proxmox_virtual_environment_container" "grafana" {
  node_name = "abhi"
  vm_id     = 107
  initialization {
    hostname = "grafana"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    type             = "ubuntu"
  }
  cpu    { cores = 2 }
  memory { dedicated = 512 }
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  started = true
}
