terraform {
  required_providers {
    proxmox = { source = "bpg/proxmox", version = "0.46.0" }
    oci     = { source = "oracle/oci", version = "~> 6.0" }
  }
}

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
# CLOUD VM 1: Grafana Management Host (Always Free AMD x86 - E2.1.Micro)
# ===================================================================
resource "oci_core_instance" "cloud_vm_1_grafana" {
  availability_domain = "KFHb:AP-MUMBAI-1-AD-1"
  compartment_id      = "ocid1.tenancy.oc1..aaaaaaaawg3kix6fkj5tsysw6h56rfsgfdd7xhpxvepeptzgb5werzw3tfya"
  display_name        = "cloud-vm-1-grafana"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaidgtby45elyebksoixjarvc4q3xttebckkgom656ofaw6tjgbt7a"
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id                 = var.oci_public_subnet_ocid
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "grafana"
    display_name              = "vnic-grafana"
  }

  metadata = {
    ssh_authorized_keys = var.laptop_ssh_public_key
  }
}

# ===================================================================
# CLOUD VM 2: Kubernetes Node Host (Always Free AMD x86 - E2.1.Micro)
# ===================================================================
resource "oci_core_instance" "cloud_vm_2_kubernetes" {
  availability_domain = "KFHb:AP-MUMBAI-1-AD-1"
  compartment_id      = "ocid1.tenancy.oc1..aaaaaaaawg3kix6fkj5tsysw6h56rfsgfdd7xhpxvepeptzgb5werzw3tfya"
  display_name        = "cloud-vm-2-kubernetes"
  shape               = "VM.Standard.E2.1.Micro"

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaidgtby45elyebksoixjarvc4q3xttebckkgom656ofaw6tjgbt7a"
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    subnet_id                 = var.oci_public_subnet_ocid
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "k8s-node"
    display_name              = "vnic-kubernetes"
  }

  metadata = {
    ssh_authorized_keys = var.laptop_ssh_public_key
  }
}

# ===================================================================
# OPTIONAL: Ampere ARM A1 Template (2 OCPUs, 12 GB RAM)
# Uncomment when Oracle frees up ARM capacity in AP-MUMBAI-1-AD-1:
# ===================================================================
# resource "oci_core_instance" "cloud_vm_arm_k8s" {
#   availability_domain = "KFHb:AP-MUMBAI-1-AD-1"
#   compartment_id      = "ocid1.tenancy.oc1..aaaaaaaawg3kix6fkj5tsysw6h56rfsgfdd7xhpxvepeptzgb5werzw3tfya"
#   display_name        = "cloud-vm-arm-k8s"
#   shape               = "VM.Standard.A1.Flex"
#
#   shape_config {
#     ocpus         = 2
#     memory_in_gbs = 12
#   }
#
#   source_details {
#     source_type             = "image"
#     source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa2op2x2s5rnduo5osx6zojr526qxtrvhddkdhks5nllbwjzcylwya"
#     boot_volume_size_in_gbs = 50
#   }
#
#   create_vnic_details {
#     subnet_id                 = var.oci_public_subnet_ocid
#     assign_public_ip          = true
#     assign_private_dns_record = true
#     hostname_label            = "k8s-arm"
#     display_name              = "vnic-k8s-arm"
#   }
#
#   metadata = {
#     ssh_authorized_keys = var.laptop_ssh_public_key
#   }
# }
