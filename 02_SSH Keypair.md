# Module 2: SSH Keypair for Terraform + Ansible

## Overview

This module guides you through creating and configuring an SSH keypair
inside **WSL Ubuntu** to be used later with **Terraform** (for
provisioning VMs) and **Ansible** (for configuration management).

------------------------------------------------------------------------

## ✅ What You Will Do

-   Create a secure RSA SSH keypair\
-   Store it in `~/.ssh/`\
-   Set correct permissions\
-   Optionally add the private key to the SSH agent\
-   Prepare the keys for upcoming Terraform & Ansible automation

------------------------------------------------------------------------

## 🔐 Step 1: Create SSH Keypair

Run this command inside WSL:

``` bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure -C "azure-terraform-ansible" -N ""
```

This generates: - **Private key** → `~/.ssh/id_rsa_azure` - **Public
key** → `~/.ssh/id_rsa_azure.pub`

------------------------------------------------------------------------

## 🔧 Step 2: Set Secure Permissions

``` bash
chmod 600 ~/.ssh/id_rsa_azure
ls -l ~/.ssh/id_rsa_azure*
```

You should see permissions similar to:

    -rw------- 1 user user 3243 id_rsa_azure
    -rw-r--r-- 1 user user  742 id_rsa_azure.pub

------------------------------------------------------------------------

## 🚀 Step 3: (Optional) Add Private Key to ssh-agent

Start the agent:

``` bash
eval "$(ssh-agent -s)"
```

Add the key:

``` bash
ssh-add ~/.ssh/id_rsa_azure
```

------------------------------------------------------------------------

## 🧪 Verification

You can print the public key:

``` bash
cat ~/.ssh/id_rsa_azure.pub
```

You will later paste this into Terraform VM configuration.

------------------------------------------------------------------------

## 🎯 Hands-on Module Work

### ✔ Generate SSH keypair

### ✔ Secure the private key

### ✔ View the public key

### ✔ Add to ssh-agent (optional)

### ✔ Use the public key in Terraform later

### ✔ After VM creation, test SSH with:

``` bash
ssh -i ~/.ssh/id_rsa_azure username@vm_public_ip
```

------------------------------------------------------------------------

