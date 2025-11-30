# Module 9: Docker — Build, Run, Push, and Pull Containers (WSL2 + Windows)

## Overview

This module walks you through the complete Docker workflow on Windows 11 using WSL2, including:

---

## ✅ What You Will Do

- Setting up Docker Desktop with WSL integration
- Creating project files (index.html, Dockerfile)
- Building Docker images
- Running containers locally
- Pushing images to Docker Hub
- Pulling images and running them anywhere

---

## 🐳 Step 1: Install & Configure Docker Desktop (WSL2)

Install Steps:

- Download Docker Desktop:
 https://docs.docker.com/desktop/install/windows-install/

Install with defaults

Enable:
- Use WSL 2 Backend
- Enable Integration for Ubuntu

Verify WSL Integration

In Docker Desktop:

```rust
Settings → Resources → WSL Integration → Enable for Ubuntu
```
---

## 🧪 Step 2:  Verify Docker Inside WSL

Open Ubuntu (WSL) and run:
```
docker --version
docker info
docker run --rm hello-world
```

If “Hello from Docker!” appears → Docker is installed and linked to WSL correctly.

---

## 🗂️ Step 3: Create Project Structure
```bash
mkdir docker-demo
cd docker-demo
```
Create index.html
```
nano index.html
```

Paste:
```html
<html>
  <body>
    <h1>Hello from Docker!</h1>
  </body>
</html>
```

Save → CTRL + O → Enter → CTRL + X.


---

## 📄 Step 4: Create Dockerfile
```bash
nano Dockerfile
```

Paste:
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

This uses a lightweight Nginx image and serves your custom HTML file.

---

## 🏗️ Step 5: Build the Docker Image (NO Tagging Needed)

Because your Docker Hub username is included in the tag, no extra tagging is required later.
```bash
docker build -t mridu0703/myhtmlapp:1.0 .
```

Check the built image:
```bash
docker images
```

---

## ▶️ Step 6: Run the Image Locally
```bash
docker run -d -p 8080:80 --name myhtmlcontainer mridu0703/myhtmlapp:1.0
```

Open browser:
```arduino
http://localhost:8080
```
Stop & remove container:
```bash
docker stop myhtmlcontainer
docker rm myhtmlcontainer
```

---

## 🔐 Step 7: Login to Docker Hub
```bash
docker login
```

Enter:
- Username → mridu0703
- Password or Access Token

## ☁️ Step 8: Push Image to Docker Hub
```bash
docker push mridu0703/myhtmlapp:1.0
```

The repository will automatically appear on:
```arduino
https://hub.docker.com/u/mridu0703
```

## 📥 Step 9: Pull Image from Docker Hub (Any Machine)
```bash
docker pull mridu0703/myhtmlapp:1.0
```

---

## ▶️ Step 10: Run Pulled Image
```bash
docker run -d -p 8080:80 --name pulledhtmlcontainer mridu0703/myhtmlapp:1.0
```

Open:
```
http://localhost:8080
```

You should see your custom HTML served through Nginx.

---

## 🧠 How to Know If Local or Pulled Image Is Running
```bash
docker ps
```

---

## 🎯 Hands-on Projects
### ✔ Modify HTML & Rebuild

Change text inside index.html, then:
```bash
docker build -t mridu0703/myhtmlapp:2.0 .
docker push mridu0703/myhtmlapp:2.0
```
### ✔ Create Multiple Tags

Experiment with:
```ruby
:dev
:prod
:testing
```
### ✔ Clean Docker Environment
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker image prune -a
```
