# 07 — Deployment & Teardown scripts

> This document describes the two shell scripts used to deploy and destroy an Azure VM + Nginx setup using Terraform and Ansible.

**Files covered**

- `deploy.sh` — automates `terraform apply`, generates an Ansible inventory, waits for the VM, runs the Ansible playbook to install/configure Nginx, and opens the site in a browser.
- `destroy.sh` — runs `terraform destroy -auto-approve` to remove created cloud resources.

---

## Quick summary

- **Purpose:** provide a small, reproducible workflow to create an Azure VM (via Terraform), configure it with Nginx (via Ansible), and then tear the infrastructure down when no longer needed.
- **Assumptions:** Terraform configuration files and an Ansible `playbook.yml` are present in the same working directory along with SSH key `~/.ssh/id_rsa_azure` and Terraform outputs a `vm_public_ip` value.

---

- deploy.sh
```shell
#!/bin/bash
# ==========================================================
# Azure VM + Nginx Auto Deployment using Terraform & Ansible
# ==========================================================

set -e  # Exit immediately if a command fails

echo "🚀 Starting Azure deployment using Terraform..."

# 1️⃣ Initialize Terraform
terraform init -input=false

# 2️⃣ Apply Terraform to create resources
terraform apply -auto-approve

# 3️⃣ Get the new public IP from Terraform output
VM_IP=$(terraform output -raw vm_public_ip)
echo "✅ VM Public IP: $VM_IP"

# 4️⃣ Create the Ansible hosts inventory file dynamically
echo "[web]" > hosts
echo "$VM_IP ansible_user=azureuser ansible_private_key_file=~/.ssh/id_rsa_azure" >> hosts

echo "✅ Ansible inventory file created: hosts"
cat hosts

# 5️⃣ Wait for VM to fully boot (optional but recommended)
echo "⏳ Waiting 30 seconds for VM to be ready..."
sleep 30

# 6️⃣ Run the Ansible playbook to configure Nginx
echo "🛠️ Running Ansible playbook to install and configure Nginx..."
ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure

# 7️⃣ Display final info
echo "🌍 Deployment complete!"
echo "Access your Nginx web server at: http://$VM_IP"
echo "To destroy resources later, run: terraform destroy -auto-approve"

# Try to open the site automatically (Linux only)
if command -v xdg-open &> /dev/null; then
  xdg-open "http://$VM_IP"
fi

```
## deploy.sh — high-level behavior

**What it does (in order):**

1. `set -e` — exit immediately if any command fails.
2. Runs `terraform init` (non-interactively).
3. Runs `terraform apply -auto-approve` to create resources.
4. Reads the Terraform output `vm_public_ip` into a variable and prints it.
5. Writes a simple Ansible inventory file `hosts` with the public IP and SSH information.
6. Waits 30 seconds to let the VM boot.
7. Runs `ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure` to configure the server (install Nginx).
8. Prints final instructions and attempts to open the server URL using `xdg-open` if available.

**Usage**

```bash
# make script executable once
chmod +x deploy.sh

# run it
./deploy.sh
```

**Important configuration points**

- Terraform must expose a raw output named `vm_public_ip` (for example: `output "vm_public_ip" { value = azurerm_public_ip.example.ip_address }`).
- The Ansible inventory that the script generates assumes the Ansible remote user is `azureuser` and private key path is `~/.ssh/id_rsa_azure`.
- Ensure `playbook.yml` exists in the same folder and is written to configure Nginx on the target VM.

**Prerequisites**

- `terraform` CLI installed and available in `PATH`.
- `ansible` and `ansible-playbook` available.
- `ssh` private key at `~/.ssh/id_rsa_azure` with proper permissions.
- Working Terraform configuration in the current directory.

**Potential improvements / hardening**

- Make the SSH username, private key path, Terraform output name, and inventory filename configurable via environment variables or CLI flags.
- Replace the fixed `sleep 30` with a loop that polls SSH/TCP port 22 until the host is reachable.
- Validate that `terraform output -raw vm_public_ip` returns a non-empty value and fail early with a helpful message if it does not.
- Avoid writing plaintext private key paths into inventory; use Ansible `--private-key` as already done or use SSH agent forwarding.

---

## destroy.sh — high-level behavior

- destroy.sh
```shell
#!/bin/bash
echo "💣 Destroying all Azure resources..."
terraform destroy -auto-approve
echo "✅ All resources destroyed successfully."

```
**What it does:**

- Prints a message and runs `terraform destroy -auto-approve` to delete all resources the Terraform state knows about.

**Usage**

```bash
chmod +x destroy.sh
./destroy.sh
```

**Cautions**

- `terraform destroy -auto-approve` will remove ALL resources tracked by the current Terraform working directory and state. Make sure you are in the correct directory and using the correct state file/workspace before running this script.
- If your Terraform state is remote (e.g., Azure Storage backend), the script will operate on that state—double check backend configuration.

**Potential improvements**

- Add a dry-run mode: `terraform plan -destroy` so the user can review what will be removed.
- Add confirmation prompt (or a `--force` flag) to avoid accidental destruction.

---

## Troubleshooting

- **`terraform` command not found** — install and configure Terraform.
- **`ansible-playbook` fails to connect** — ensure the correct IP, correct SSH key, and that the VM's NSG allows SSH (port 22) from your IP.
- **`terraform output -raw vm_public_ip` returns nothing** — check your Terraform outputs and run `terraform output` manually.
- **`xdg-open` doesn't open a browser on non-Linux OS** — the script only attempts `xdg-open` on systems that provide it.

---

## Example workflow

1. `./deploy.sh` — creates infra and configures Nginx.
2. Visit the printed URL (http://<vm_public_ip>) to verify Nginx.
3. When finished, run `./destroy.sh` to delete resources.

---


