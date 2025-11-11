# 📘 DevOps Roadmap

Welcome to the Complete DevOps Summary!  

This repository walks you through a practical, end-to-end workflow: **set up your environment**, **provision Azure infrastructure with Terraform**, **configure with Ansible**, **automate deploy/teardown with scripts**, and optionally **bake a reusable image with Packer**.

Each module includes core ideas, exact commands, and hands-on tasks.

<img width="1899" height="1060" alt="image" src="https://github.com/user-attachments/assets/06aba1e0-2981-4b37-b179-c46d6396ddee" />

---

### 🧠 Module 1: Setup — WSL2 + Ubuntu + CLI Tools

- **What you do**

  - Enable WSL2 on Windows 11 and install Ubuntu (`wsl --install` in PowerShell Admin).

  - In WSL Ubuntu, install: Azure CLI, Terraform, Ansible, Git, jq.

  - Verify installs and prepare for next steps.

- **Key commands**

  - `az --version`, `terraform -version`, `ansible --version`

- **Hands-on Projects**

  - Install and verify all tools inside WSL Ubuntu.

  - Record versions and troubleshoot PATH issues if needed.

---

### 🔐 Module 2: SSH Keypair for Terraform + Ansible

- **What you do**

  - Create SSH keypair in WSL: `~/.ssh/id_rsa_azure` and `~/.ssh/id_rsa_azure.pub`.

  - Set secure permissions and optionally add to `ssh-agent`.

- **Key commands**

  - `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_azure -C "azure-terraform-ansible" -N ""`

  - `chmod 600 ~/.ssh/id_rsa_azure` and `ls -l ~/.ssh/id_rsa_azure*`

- **Hands-on Projects**

  - Use the public key in Terraform later; test private key with SSH once VM exists.

---

### 🔑 Module 3: Authenticate to Azure (Dev vs CI/CD)

- **Developer mode**

  - `az login`, select subscription if needed.

- **Service Principal (CI/CD)**

  - Create SP with `az ad sp create-for-rbac ...` and export `ARM_*` vars.

- **Hands-on Projects**

  - Verify: `az account show` and `env | grep ARM_`

---

### 🏗️ Module 4: Terraform Project Files (Azure VM)

- **What you do**

  - Create `providers.tf`, `variables.tf`, `main.tf`, `outputs.tf` (+ optional `terraform.tfvars`).

  - Provision RG, VNet/Subnet, NSG (22/80/443), Public IP, NIC, Ubuntu 22.04 VM with SSH key.

- **Workflow**

  - `terraform init` → `terraform validate` → `terraform plan` → `terraform apply`

  - Outputs include `vm_public_ip` for connectivity.

- **Hands-on Projects**

  <img width="1883" height="928" alt="image" src="https://github.com/user-attachments/assets/73d9cc4d-3e7c-4e44-9fa2-01642e24fd95" />

  - Parameterize location/VM size; add tags; re-apply safely.

---

### 📇 Module 5: Prepare Ansible Inventory from Terraform Output

- **What you do**

  - Read VM IP via Terraform output and create `hosts` inventory with `[web]` group.

- **Key commands**

  - `VM_IP=$(terraform output -raw vm_public_ip)`

  - Generate `hosts` with `ansible_user` and `ansible_private_key_file`.

- **Hands-on Projects**

  - Test SSH to the VM; validate inventory by pinging hosts with Ansible.

---

### 🧰 Module 6: Ansible Playbook — Install and Configure Nginx

- **What you do**

  - Create `playbook.yml` to update apt, install Nginx, enable service, and write an index page.

- **Run**

  - `ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure`

- **Hands-on Projects**

  - Parameterize index content; ensure idempotency; verify `http://<VM_IP>/`.

---

### 🚀 Module 7: Deployment & Destroy Scripts

- **deploy.sh**

  - Init/apply Terraform, fetch IP, generate inventory, wait, run playbook, print URL.

- **destroy.sh**

  - `terraform destroy -auto-approve` to remove all resources.

- **Hands-on Projects**

  - Replace static sleep with SSH wait loop; add flags for username/key path.

---

### 🧱 Module 8: Create Custom Azure Image with Packer (Optional)

- **What you do**

  - Author `nginx-azure.pkr.hcl` to build Ubuntu + Nginx managed image.

- **Workflow**

  - `packer init` → `packer validate` → `packer build`

  - Verify with `az image list`; reference in Terraform via `source_image_id`.

- **Hands-on Projects**

  - Customize homepage during build; parameterize variables; promote images per environment.

---

**Happy Shipping! 🚀**


