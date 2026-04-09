#!/bin/bash

# Update system and install dependencies
sudo apt update
sudo apt install fontconfig openjdk-21-jre
java -version

# Add Jenkins repository and key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins

# Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# System update and Docker installation
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io -y
sudo systemctl status docker
sudo systemctl start docker

# Add users to Docker group
sudo usermod -aG docker ubuntu jenkins

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Show initial Jenkins admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword