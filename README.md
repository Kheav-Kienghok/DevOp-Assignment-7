# 🚀 DevOps Assignment 7

This repository demonstrates a simple CI/CD setup using Jenkins, Docker, AWS EC2, AWS CLI, and Terraform. The environment is provisioned and configured with an automated shell script.

## Prerequisites

- AWS account
- Basic understanding of EC2 and SSH
- GitHub access

## Step 1: Create an EC2 Instance

1. Open the AWS EC2 console.
2. Launch an Ubuntu instance with the following settings:
   - Instance type: `t3.medium`
   - Security group inbound rules:
     - SSH (`22`)
     - HTTP (`80`) (optional)
     - Custom TCP (`8080`) for Jenkins
3. Connect to the instance:

```bash
ssh -i your-key.pem ubuntu@<EC2_PUBLIC_IP>
```

## Step 2: Install Jenkins, Docker, Terraform, and AWS CLI

Download the setup script:

```bash
curl -O https://raw.githubusercontent.com/Kheav-Kienghok/DevOp-Assignment-7/main/main.sh
```

Run the script:

```bash
bash main.sh
```

The script installs and configures Jenkins, Docker, Terraform, and AWS CLI automatically.

## Step 3: Verify Installation

- Jenkins starts automatically.
- Docker starts automatically.
- AWS CLI and Terraform are available after setup.

If log output is attached to the terminal, press `q` to return to the shell.

## Step 4: Access Jenkins

1. Copy the initial Jenkins admin password printed by the script.
2. Open:

```bash
http://<EC2_PUBLIC_IP>:8080
```

3. Paste the password to unlock Jenkins.

## Step 5: Install Required Plugin

In Jenkins, go to:

`Manage Jenkins` -> `Plugins` -> `Available plugins`

Install:

- AWS Credentials

## Step 6: Configure AWS Credentials

1. Go to:

`Manage Jenkins` -> `Credentials` -> `Global`

2. Add credentials with:
   - Kind: AWS Credentials
   - ID: `aws-creds`
   - Description: any meaningful description
   - Access Key ID: your key
   - Secret Access Key: your secret
3. Save.

## Step 7: Configure Jenkins Pipeline

1. Open Jenkins Dashboard.
2. Click **New Item**.
3. Choose **Pipeline**.
4. Configure the job to use your GitHub repository and `Jenkinsfile`.

## Step 8: Run the Pipeline

- Click **Build Now**.
- Monitor each stage in the build logs.
- Confirm that all stages complete successfully.

## ✅ Expected Result

- Jenkins is running on EC2.
- Docker is installed and available.
- AWS CLI is configured.
- The CI/CD pipeline runs successfully.

Example success output:

```bash
[Pipeline] echo
Deployment successful. App is running at http://<EC2_PUBLIC_IP>
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

## Notes

- Make sure port `8080` is open in your EC2 security group.
- Keep AWS credentials secure and never commit them to source control.
- Stop the EC2 instance when not in use to avoid unnecessary charges.
