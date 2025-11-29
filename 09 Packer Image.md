# Module 8: Create Custom Azure Image with Packer (Optional)

## Overview
This optional module shows how to create a **custom Azure-managed VM image** using **Packer**.  
This image can later be used in Terraform deployments to ensure consistent and repeatable server builds (e.g., Ubuntu + Nginx pre-installed).

---

## 🧱 What You Will Do
- Write a Packer template: **`nginx-azure.pkr.hcl`**
- Build an Azure image using Packer
- Validate and inspect the generated custom image
- Use the image in Terraform via `source_image_id`
- Optionally customize Nginx homepage and parameterize build variables

---

## 📁 Example Packer Template Structure

Your file (example):  
**`nginx-azure.pkr.hcl`**

Typical components:
- Variables (location, image SKU, resource group, etc.)
- Azure builder block
- Provisioners to install Nginx + custom files
- Output image configuration

`nginx-azure.pkr.hcl`
```
packer {
  required_plugins {
    azure = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/azure"
    }
    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type      = string
  sensitive = true
  default   = ""
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "resource_group" {
  type    = string
  default = "packer-images-rg"
}

variable "location" {
  type    = string
  default = "eastasia"
}

source "azure-arm" "nginx" {
  managed_image_name                = "nginx-vm-image"
  managed_image_resource_group_name = var.resource_group
  location                          = var.location

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  ssh_username = "azureuser"
  vm_size      = "Standard_B1s"

  azure_tags = {
    environment = "dev"
    purpose     = "nginx-image"
  }
}

build {
  name    = "nginx-image-build"
  sources = ["source.azure-arm.nginx"]

  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/playbook.yml"

    extra_arguments = [
      "--ssh-extra-args", "-o IdentitiesOnly=yes",
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"
    ]

    use_proxy = false
  }
}

```
---

## 🔄 Packer Workflow

### **1️⃣ Initialize Packer environment**
```bash
packer init .
```

### 2️⃣ Validate the template
```bash
packer validate nginx-azure.pkr.hcl
```

### 3️⃣ Build the custom image
```bash
packer build nginx-azure.pkr.hcl
```
This creates a Managed Image inside your Azure subscription and resource group.

## 🧪 Verification

List available images
```bash
az image list --output table
```
Look for the image created by your Packer build.

## 🧩 Using Image in Terraform

After Packer build, copy the `id` of the managed image:

Example snippet in Terraform:

```hcl
source_image_id = "/subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Compute/images/<image-name>"
```

This ensures VMs created via Terraform include:

- Ubuntu
- Nginx
- Customizations made at image-build time

## 🛠️ Hands-On Module Work
### ✔ Build custom Ubuntu + Nginx Packer image
### ✔ Customize homepage during build (Optional)
### ✔ Parameterize variables using variables.pkr.hcl
### ✔ Promote images across Dev → Staging → Production
### ✔ Reference custom image inside Terraform
