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
