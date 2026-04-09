pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        IMAGE_NAME = "foodexpress-app"
        TAG = "latest"
        KEY_NAME = "foodexpress-auto-key"
        TF_ENV = "prod"
    }

    stages {

        stage("Checkout Code") {
            steps {
                git branch: "main", url: "https://github.com/Kheav-Kienghok/DevOp-Assignment-7.git"
            }
        }

        stage("Load AWS Credentials") {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                        echo "AWS credentials loaded successfully"
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage("Generate SSH Key Pair") {
            steps {
                sh """
                    mkdir -p sshkey
                    if [ ! -f sshkey/id_rsa ]; then
                    ssh-keygen -t rsa -b 4096 -f sshkey/id_rsa -N ""
                    chmod 600 sshkey/id_rsa
                    fi
                """
            }
        }

        stage("Build Docker Image (Jenkins)") {
            steps {
                sh """
                    docker build -t ${IMAGE_NAME}:${TAG} ./app
                """
            }
        }

        stage("Save Docker Image to TAR") {
            steps {
                sh """
                    rm -f ${IMAGE_NAME}.tar
                    docker save -o ${IMAGE_NAME}.tar ${IMAGE_NAME}:${TAG}
                """
            }
        }

        stage("Check Terraform Availability") {
            steps {
                sh """
                    command -v terraform
                    terraform version
                """
            }
        }

        stage("Terraform Destroy (Clean State)") {
            steps {
                dir("terraform/${TF_ENV}") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh """
                            terraform init
                            terraform destroy -auto-approve \
                            -var="aws_region=${AWS_REGION}" \
                            -var="key_name=${KEY_NAME}" \
                            -var="public_key=\$(cat ../../sshkey/id_rsa.pub)" || true
                        """
                    }
                }
            }
        }

        stage("Terraform Apply (Provision EC2)") {
            steps {
                dir("terraform/${TF_ENV}") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh """
                            terraform init
                            terraform apply -auto-approve \
                            -var="aws_region=${AWS_REGION}" \
                            -var="key_name=${KEY_NAME}" \
                            -var="public_key=\$(cat ../../sshkey/id_rsa.pub)"
                        """
                    }
                }
            }
        }

        stage("Get EC2 Public IP") {
            steps {
                dir("terraform/${TF_ENV}") {
                    script {
                        env.EC2_PUBLIC_IP = sh(
                            script: "terraform output -raw public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
                echo "EC2 Public IP: ${EC2_PUBLIC_IP}"
            }
        }

        stage("Wait for EC2 SSH") {
            steps {
                sh """
                    echo "Waiting for EC2 to be ready..."
                    for i in {1..40}; do
                      ssh -o StrictHostKeyChecking=no -i sshkey/id_rsa ubuntu@${EC2_PUBLIC_IP} "echo READY" && break
                      sleep 10
                    done
                """
            }
        }

        stage("Copy Docker Image to EC2") {
            steps {
                sh """
                    scp -o StrictHostKeyChecking=no -i sshkey/id_rsa ${IMAGE_NAME}.tar ubuntu@${EC2_PUBLIC_IP}:/home/ubuntu/
                """
            }
        }

        stage("Install Docker on EC2") {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i sshkey/id_rsa ubuntu@${EC2_PUBLIC_IP} '
                        sudo apt update -y
                        sudo apt install -y docker.io

                        sudo systemctl start docker
                        sudo systemctl enable docker

                        sudo usermod -aG docker ubuntu

                        # Fix permissions immediately (no logout needed)
                        sudo chmod 666 /var/run/docker.sock
                    '
                """
            }
        }

        stage("Deploy Container on EC2") {
            steps {
                sh """
                    ssh -o StrictHostKeyChecking=no -i sshkey/id_rsa ubuntu@${EC2_PUBLIC_IP} '
                        sudo docker load -i /home/ubuntu/${IMAGE_NAME}.tar

                        sudo docker stop foodexpress || true
                        sudo docker rm foodexpress || true

                        sudo docker run -d --name foodexpress -p 80:3000 ${IMAGE_NAME}:${TAG}
                    '
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful. App is running at http://${EC2_PUBLIC_IP}"
        }
        failure {
            echo "Deployment failed"
        }
    }
}