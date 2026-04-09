# 🚀 DevOps Assignment 7

This project demonstrates a simple CI/CD pipeline setup using Jenkins, Docker, AWS EC2, and AWS CLI, automated through a setup script.

---

## 📌 Prerequisites
- AWS Account
- Basic knowledge of EC2 and SSH
- GitHub access

---

## ⚙️ Step 1: Create EC2 Instance

1. Go to AWS EC2 Dashboard  
2. Launch an instance with the following configuration:
   - Instance Type: t3.medium
   - OS: Ubuntu
   - Security Group:
     - Allow SSH (22)
     - Allow HTTP (80) *(optional)*
     - Allow Custom TCP (8080) for Jenkins

3. Connect to your instance using SSH:

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

---

## 🛠️ Step 2: Install Jenkins, Docker, and AWS CLI

Run the following command:

```bash
curl -O https://raw.githubusercontent.com/Kheav-Kienghok/DevOp-Assignment-7/main/main.sh
```

Then execute:

```bash
bash main.sh
```

### Notes:
- Press Enter twice when prompted during installation
- Jenkins, Docker, and AWS CLI will be installed automatically

---

## 🔍 Step 3: Verify Installation

- Jenkins will start automatically → press `q` to exit logs  
- Docker will start → press `q` again  
- AWS CLI will be installed at the end  

---

## 🔐 Step 4: Access Jenkins

1. Copy the initial admin password shown after installation  
2. Open your browser and go to:

```
http://<EC2_PUBLIC_IP>:8080
```

3. Paste the password to unlock Jenkins  

---

## 🔌 Step 5: Install Required Plugin

Go to:

Manage Jenkins → Plugins → Available Plugins

Install:
- AWS Credentials

---

## 🔑 Step 6: Configure AWS Credentials

1. Go to:

Manage Jenkins → Credentials → Global

2. Add new credentials:
   - Kind: AWS Credentials  
   - ID: aws-creds  
   - Description: Any description  
   - Access Key ID: ********  
   - Secret Access Key: ********  

3. Save the configuration

---

## 🔄 Step 7: Setup Jenkins Pipeline

1. Go to Jenkins Dashboard  
2. Click New Item  
3. Select Pipeline  
4. Configure:
   - Connect to your GitHub repository
   - Add your Jenkinsfile

---

## ▶️ Step 8: Run the Pipeline

- Click Build Now  
- Monitor the pipeline execution  
- Ensure all stages complete successfully  

---

## ✅ Final Result

- Jenkins is running on EC2  
- Docker is installed and ready  
- AWS CLI is configured  
- CI/CD pipeline is successfully executed  

---

## 📎 Notes
- Ensure port 8080 is open in your EC2 security group  
- Keep AWS credentials secure  
- Stop EC2 instance when not in use to avoid charges  
