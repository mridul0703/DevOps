# Module 6: Ansible Playbook — Install and Configure Nginx

## Overview
This module teaches you how to build an **Ansible playbook** that installs, configures, and manages **Nginx** on a remote VM.  
You will ensure **idempotency**, parameterize content, and validate the deployment in a browser.

---

## ✅ What You Will Do
- Create an Ansible playbook `playbook.yml`
- Update apt packages
- Install Nginx
- Enable & restart the Nginx service
- Deploy a custom index page
- Run the playbook using SSH key authentication
- Verify deployment via browser

---

## 📁 playbook.yml (Base Version)

```yaml
---
- name: Install and configure Nginx
  hosts: webservers
  become: yes
  vars:
    index_content: "Welcome to your Ansible Nginx Server!"
  
  tasks:
    - name: Update apt repository cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx is enabled and running
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create custom index.html
      copy:
        dest: /var/www/html/index.html
        content: "{{ index_content }}"
        mode: '0644'
```

This playbook is fully idempotent — re-running it will not break anything.

## 🗂️ Step 1: Inventory File (hosts)
Create a hosts file:

```ini
[webservers]
<VM_PUBLIC_IP> ansible_user=<USERNAME> ansible_python_interpreter=/usr/bin/python3
```
Replace:

- `<VM_PUBLIC_IP>` — Azure VM public IP
- `<USERNAME>` — usually the admin username created in Terraform

## ▶️ Step 2: Run the Playbook
```bash
ansible-playbook -i hosts playbook.yml --private-key ~/.ssh/id_rsa_azure
```

This will:

- SSH into the VM
- Install Nginx
- Deploy your custom index.html

## 🎯 Hands-on Projects
### ✔ Parameterize index content
Modify in vars::

```yaml
index_content: "Hello from Ansible Automation!"
```
### ✔ Maintain Idempotency
Run playbook multiple times to ensure:

- No unnecessary changes
- No reinstallation
- Service stays running

### ✔ Verify Nginx Deployment
Open browser:

```cpp
http://<VM_PUBLIC_IP>/
```
You should see your custom message.
