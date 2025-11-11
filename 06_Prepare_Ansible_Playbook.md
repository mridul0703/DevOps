# 6 — Create a simple Ansible playbook (example: install Nginx)

> Create and run a minimal Ansible playbook to install and start Nginx on your VM.

## Where to run
- Inside your Terraform/Ansible working directory in the WSL Ubuntu shell.
- Ensure your `hosts` inventory from the previous step exists and contains the `[web]` group.

## Prerequisites
- Ansible installed in WSL.
- SSH private key at `~/.ssh/id_rsa_azure` with correct permissions.
- Inventory file `hosts` with your VM’s public IP.

## 1) Create the playbook
Create `playbook.yml` with the following content:

```yaml
---
- name: Configure web server on Azure VM
  hosts: web
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Ensure nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create /var/www/html/index.html
      copy:
        dest: /var/www/html/index.html
        content: "<h1>Hello from Terraform + Ansible on Azure</h1>"
        owner: www-data
        group: www-data
        mode: '0644'
```

What this does: updates apt, installs nginx, ensures the service is running/enabled, and writes a simple index page.

## 2) Run the playbook

```bash
ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure
```

What this does: connects to the VM via SSH using your private key and executes the tasks. You’ll see per‑task output (changed/ok/failure).

## 3) Verify the result
- Open `http://<VM_IP>/` in your browser — you should see the index page.
