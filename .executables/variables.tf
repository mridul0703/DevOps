variable "location" {
  type    = string
  default = "eastasia"
}

variable "resource_group_name" {
  type    = string
  default = "tf-ansible-rg"
}

variable "vm_name" {
  type    = string
  default = "tf-ansible-vm"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_azure.pub"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}
