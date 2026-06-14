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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDpSZQtFJefbOrsGi/Fu1aA9A5h1UsW9ikokCFi13ZSlGdadLTszqkgVaBe4yhcobz+UD79cL9EJpjSzZmO8Nu7SeSEAZyvQA6Y8mcqwXkcx0FRdvkDn6MAGpkOn5db8kkmBPBPvOy8UdlGi8yQ8uAcajsEh/k5whs9mSljgCa/TbQZmbMZxrDTV7Twu6jBwdAvqYq4rw3qqPsk1BxsuzxjFwJiZsid5zYM95K99GOCktzSQd3KPK6wmXbe+TpJWvZe+IwyOJc7AMeddoAf7byM4oT0eFPGrh33MYmAEoSM8MGXMmdhutRXDt/rAfEXeWyGFIzXlpl3UyHTMSrbzIAHFRuOFUJWXlIVtaX8cJ/JSi+1i4HfgqMXSyjN63ZaWFgMegKnRGomKjZPcJGysC/UQm3HrVqc8YEHgOO9g/Ef9yVFKx682fHjaTrwzAhbinbksUutivnkBoh73OcRjj01XMrV+x9HRjYTuZc2LKUL+CzI/s5+4ziK6dHCpVZCEAvjVP6WlxK029HzDDdD9LfluYiUHXjW3aPyQc2TFoODenyBTzWaCOtuO59Ykf4O3lHADswTiXaq5wv4Jw2Gx6Sq4qKzqXSID3NB+jBBnUeTNTf+Ho4MkfDS5DKcVILDN06oABXxZWQ4LA5wt60wtLHnpEcSPvkLfgXW5JAroCK52w== abhishekmishra108@control-node"
}
