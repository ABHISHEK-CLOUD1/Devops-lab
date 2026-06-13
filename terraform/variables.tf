variable "oci_tenancy_ocid" { 
  type    = string 
  default = "ocid1.tenancy.oc1..aaaaaaaawg3kix6fkj5tsysw6h56rfsgfdd7xhpxvepeptzgb5werzw3tfya"
}

variable "oci_user_ocid" { 
  type    = string 
  default = "ocid1.user.oc1..aaaaaaaaduj6s7nybn67nzqiwhht77zx6tm3plbblote2auwwswlufoandya"
}

variable "oci_fingerprint" { 
  type    = string 
  default = "c6:12:09:a4:bc:f4:eb:87:4a:d6:b6:71:ea:78:56:49"
}

variable "oci_private_key" { 
  type    = string 
  default = "/opt/jenkins/.oci/oci_api_key.pem"
}

variable "oci_region" { 
  type    = string
  default = "ap-mumbai-1" 
}

variable "oci_public_subnet_ocid" { 
  type    = string
  default = "ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaarkmln3bzxujqfhn6ttiizwdv4ifpxbyf7yn22i2aswae3a4uh43a" 
}

variable "laptop_ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3d7c6a41abhishekmishra108@control-node"
}
