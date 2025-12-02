# Module 10: Docker End-to-End Workflow (Build → Run → Push → Pull → Deploy)

## Overview
This module walks through the complete Docker workflow using **WSL + Docker Desktop**.

You will:

- Build a Docker image from a Dockerfile  
- Instantiate & run a container locally  
- Test your containerized application  
- Push the image to Docker Hub  
- Pull the image from Docker Hub  
- Deploy the pulled image  

This workflow supports consistent, repeatable, portable application deployments.

---

## 🧱 What You Will Do
- Create and build a Docker image (`docker build`)  
- Run containers locally (`docker run`)  
- Validate and test application in browser or via curl  
- Push images to Docker Hub (`docker push`)  
- Pull images from Docker Hub (`docker pull`)  
- Redeploy the pulled image

---

## 📁 Example Project Structure

Your working directory contains:
```bash
Dockerfile
index.html
```

Typical tasks:
- Build image from Dockerfile  
- Run container mapping ports  
- Push/tag image for Docker Hub  
- Pull same image on another machine  

---

## 📦 Dockerfile (Example)

Dockerfile  
```bash
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

---

# 🔄 Docker Workflow

## 1️⃣ Build the Docker Image

```bash
cd /path/to/project
```
```bash
docker build -t myapp:latest .
```
---

## 2️⃣ Run a New Container Locally

```bash
docker run -d -p 8080:80 --name myapp_container myapp:latest
```
---

## 3️⃣ Test Your Application

### Test with curl:
```bash
curl http://localhost:8080
```
### Or open in browser:

```curl
http://localhost:8080
```

---

# ☁️ Push Image to Docker Hub

## 4️⃣ Login to Docker Hub

```bash
docker login
```
## 5️⃣ Tag the Image for Docker Hub

```bash
docker tag myapp:latest your_dockerhub_username/myapp:latest
```
## 6️⃣ Push the Image

```bash
docker push your_dockerhub_username/myapp:latest
```
---

# 📥 Pull Image from Docker Hub

## 7️⃣ Pull the Image

```bash
docker pull your_dockerhub_username/myapp:latest
```
### Verify pull:
```bash
docker images
```
---

# 🚀 Deploy the Pulled Image

## 8️⃣ Run a Container from Pulled Image

```bash
docker run -d -p 8080:80 --name deployed_myapp your_dockerhub_username/myapp:latest
```
## Test Deployment

```bash
curl http://localhost:8080
```
or open:
```curl
http://localhost:8080
```
---

# 🧪 Verification Commands

### List containers:
```bash
docker ps -a
```
### List local images:
```bash
docker images
```
### View container logs:
```bash
docker logs myapp_container
```
---

# 🧩 Optional Enhancements

- Automate image versioning  
- Build + push from CI/CD (GitHub Actions, Azure DevOps)  
- Use multi-stage Docker builds  
- Secure images with Docker Hub private repositories  
- Add environment variables using `-e`  
- Add bind mounts or volumes  

---

# 🛠️ Hands-On Module Work

✔ Build Docker image from Dockerfile  
✔ Run container locally  
✔ Test app via curl/browser  
✔ Push image to Docker Hub  
✔ Pull image back down  
✔ Deploy image on WSL  
✔ Repeatable workflow for any app  

---

