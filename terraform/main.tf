terraform {
  required_providers {
    proxmox = { source = "bpg/proxmox", version = "0.46.0" }
    oci     = { source = "oracle/oci", version = "~> 5.0" }
  }
}

# Empty local provider skeleton to satisfy dependency structures
provider "proxmox" {
  endpoint  = "https://192.168.155.128:8006/"
  api_token = "root@pam!terraform=bff2d81c-dce2-4fe5-ad89-66800425ec59"
  insecure  = true
}

provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key
  region           = var.oci_region
}

# ===================================================================
# CLOUD VM 1: Grafana Management Host
# ===================================================================
resource "oci_core_instance" "cloud_vm_1_grafana" {
  availability_domain = "ZjLz:AP-MUMBAI-1-AD-2" 
  compartment_id      = var.oci_tenancy_ocid
  display_name        = "cloud-vm-1-grafana"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaannu6wglvsw3mscoxl2742vovff2g27z6is4orj5zndxghqgl4bfa" 
    boot_volume_size_in_gbs = 50  # Added explicit Free Tier allocation
  }

  create_vnic_details {
    subnet_id        = var.oci_public_subnet_ocid
    assign_public_ip = true
    display_name     = "vnic-grafana"
  }

  metadata = {
    ssh_authorized_keys = var.laptop_ssh_public_key
  }
}

# ===================================================================
# CLOUD VM 2: Kubernetes Node Host
# ===================================================================
resource "oci_core_instance" "cloud_vm_2_kubernetes" {
  availability_domain = "ZjLz:AP-MUMBAI-1-AD-2" 
  compartment_id      = var.oci_tenancy_ocid
  display_name        = "cloud-vm-2-kubernetes"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 3
    memory_in_gbs = 18
  }

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaannu6wglvsw3mscoxl2742vovff2g27z6is4orj5zndxghqgl4bfa" 
    boot_volume_size_in_gbs = 50  # Added explicit Free Tier allocation
  }

  create_vnic_details {
    subnet_id        = var.oci_public_subnet_ocid
    assign_public_ip = true
    display_name     = "vnic-kubernetes"
  }

  metadata = {
    ssh_authorized_keys = var.laptop_ssh_public_key
  }
}
