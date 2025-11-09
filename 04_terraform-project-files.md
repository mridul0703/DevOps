# Create Terraform Project Files — Full Detailed Guide

**File:** `terraform-project-files.md`  
**Purpose:** Set up and understand a complete Terraform configuration for deploying an Azure Virtual Machine.

---

## 1 — Where to run and save

All commands below are to be executed **inside your WSL Ubuntu shell**.

### Create your working directory:
```bash
mkdir -p ~/azure-terraform-ansible
cd ~/azure-terraform-ansible
```
This directory will hold all Terraform configuration files.

---

## 2 — Why we are doing this

Terraform needs a set of configuration files written in HashiCorp Configuration Language (HCL).
Each file defines what infrastructure to create, how it should behave, and how outputs are handled.

The common structure includes:
- providers.tf → defines the cloud provider (Azure)
- variables.tf → stores reusable input variables
- main.tf → the main logic (infrastructure resources)
- outputs.tf → defines values Terraform should print after apply
- terraform.tfvars → stores variable overrides (optional, often excluded from git)

---

## 3 — Files and their roles

- 📘 providers.tf
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
  # Authentication:
  # - If you've done `az login` in this shell, provider will use Azure CLI authentication.
  # - If you exported ARM_* env vars (service principal), azurerm will use them instead.
}
```

🔍 Explanation
- terraform {} block defines global Terraform settings.
  - required_providers: tells Terraform to use the AzureRM provider (HashiCorp’s official plugin).
  - required_version: ensures Terraform CLI version compatibility.
- provider "azurerm": configures Azure Resource Manager plugin.
  - The features {} block is required by AzureRM provider (can remain empty).
  - Authentication is handled automatically via:
    - Azure CLI (if you ran az login), or
    - Environment variables (ARM_CLIENT_ID, etc.) if using Service Principal.

---

- 📗 variables.tf
```hcl
variable "location" {
  type    = string
  default = "eastus"
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

```

🔍 Explanation

- **Why use variables?**<br>
  They make configurations reusable and cleaner. You can change values without editing every resource.

- Each variable block:
  - type defines expected data type (string, number, bool, etc.).
  - default provides fallback value.

- The ssh_public_key_path tells Terraform where to find your public SSH key (for secure VM login).

---

- 📙 main.tf
```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_group_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_group_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
  name                       = "AllowHTTPS"
  priority                   = 1003
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

}


resource "azurerm_public_ip" "pubip" {
  name                = "${var.resource_group_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pubip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy" # Ubuntu 22.04 LTS
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  tags = {
    Environment = "Terraform-Ansible"
  }
}

```

🔍 Explanation

This is the core of your Terraform infrastructure.

Each resource block defines an Azure component:

- Resource Group: Container for all Azure resources.
- Virtual Network (VNet): Internal network for resources.
- Subnet: Subdivision of the VNet for organization/security.
- NSG (Network Security Group): Firewall rules controlling inbound/outbound traffic.
  - Here, we open port 22 (SSH).
- Public IP: Allows external access.
- NIC (Network Interface Card): Connects VM to the network.
- NIC-NSG Association: Binds firewall rules to your VM NIC.
- Linux Virtual Machine: Creates Ubuntu 22.04 LTS instance with your SSH public key.

Terraform automatically determines dependencies (e.g., VM after NIC, NIC after subnet, etc.).

---

- 📒 outputs.tf

```hcl
output "vm_public_ip" {
  description = "Public IP of VM"
  value       = azurerm_public_ip.pubip.ip_address
}

output "vm_username" {
  value = var.admin_username
}

```

🔍 Explanation

- output blocks tell Terraform which values to display after terraform apply.
- Useful for quick reference — e.g., the public IP for SSH connection.

You can run:
```bash
terraform output vm_public_ip
```
to see your VM's public IP.

---

- 📄 terraform.tfvars (optional)

```hcl
location            = "eastus"
resource_group_name = "my-tf-ansible-rg"
vm_name             = "my-ubuntu-vm"
```

🔍 Explanation

- This optional file overrides variable defaults in variables.tf.
- Never store secrets here (like passwords or SP credentials).
- Add it to .gitignore if it contains sensitive info.

---

## 4 — Initialize Terraform

Once files are ready, initialize Terraform:

```bash
terraform init
```
What it does:

- Downloads provider plugins (like azurerm).
- Prepares working directory with .terraform folder.

## 5 — Validate and Plan

Validate your configuration syntax:

```bash
terraform validate
```

Preview what Terraform will create:

```bash
terraform plan
```

---

## 6 — Apply (Provision the VM)

Execute:

```bash
terraform apply
```

Review the plan, type yes when prompted.

Terraform will:

- Create a resource group
- Create networking components
- Create an Ubuntu VM
- Output your public IP and username

---

## 7 — Connect to your VM

Once complete, get the public IP:

```bash
terraform output vm_public_ip
```

Then SSH in:

```bash
ssh azureuser@<public_ip> -i ~/.ssh/id_rsa_azure
```

---

## 8 — Clean up

To destroy everything Terraform created:

```bash
terraform destroy
```

---

## 9 — Summary Table
| File	| Purpose |	Key | Concept | 
|-------|----------|-----|----------|
| providers.tf	| Provider setup	| Connect Terraform to Azure | 
| variables.tf	| Input vars	| Dynamic configuration | 
| main.tf	| Resources	| Actual Azure infrastructure |
| outputs.tf	| Output values	| View IPs, usernames |
| terraform.tfvars	| Overrides	| Optional environment customization |

---
