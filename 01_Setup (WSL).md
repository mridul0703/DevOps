# Module 1: Setup --- WSL2 + Ubuntu + CLI Tools

## Overview

This module guides you through setting up **WSL2**, installing
**Ubuntu**, and configuring essential **DevOps/System Design tooling**
inside the WSL environment.

------------------------------------------------------------------------

## ✅ What You Will Do

-   Enable **WSL2** on Windows 11\
-   Install **Ubuntu** using `wsl --install`\
-   Install essential CLI tools inside Ubuntu:
    -   **Azure CLI**
    -   **Terraform**
    -   **Ansible**
    -   **Git**
    -   **jq**
-   Verify installations\
-   Fix potential PATH issues

------------------------------------------------------------------------

## 🖥️ Step 1: Enable WSL2 & Install Ubuntu

Open **PowerShell (Admin)** and run:

``` bash
wsl --install
```

This automatically: - Enables WSL\
- Installs WSL2\
- Installs Ubuntu as the default distribution

Restart your system when prompted.

------------------------------------------------------------------------

## 🐧 Step 2: Initial Ubuntu Setup

Open Ubuntu from Start Menu and create your Linux username + password.

Update packages:

``` bash
sudo apt update && sudo apt upgrade -y
```

------------------------------------------------------------------------

## 🔧 Step 3: Install Required Tools

### **Install Azure CLI**

``` bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### **Install Terraform**

``` bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

### **Install Ansible**

``` bash
sudo apt update
sudo apt install ansible -y
```

### **Install Git**

``` bash
sudo apt install git -y
```

### **Install jq**

``` bash
sudo apt install jq -y
```

------------------------------------------------------------------------

## 🧪 Step 4: Verify Installations

Run the following commands:

``` bash
az --version
terraform -version
ansible --version
git --version
jq --version
```

All tools should return their versions.

------------------------------------------------------------------------

## 🧰 Troubleshooting (PATH Issues)

If any command shows "not found":

``` bash
echo $PATH
```

Add missing tool path:

``` bash
export PATH=$PATH:/usr/local/bin
```

Make permanent:

``` bash
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

------------------------------------------------------------------------

## 🏁 Hands‑on Module Work

### ✔ Install and verify all tools inside WSL Ubuntu

### ✔ Record tool versions

### ✔ Fix PATH or installation issues if encountered

------------------------------------------------------------------------
