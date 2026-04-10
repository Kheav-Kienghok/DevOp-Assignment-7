pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        IMAGE_NAME = "foodexpress-app"
        IMAGE_TAR  = "foodexpress-app.tar"
        TAG = "${env.BUILD_NUMBER}"
        KEY_NAME = "foodexpress-auto-key"
        TF_ENV = "prod"
        TF_DIR = "terraform/prod"
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
                        set -e
                        echo "AWS credentials loaded successfully"
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage("Generate SSH Key Pair") {
            steps {
                sh '''
                    set -e
                    mkdir -p sshkey

                    if [ ! -f sshkey/id_rsa ]; then
                        echo "Generating SSH key pair..."
                        ssh-keygen -t rsa -b 4096 -f sshkey/id_rsa -N ""
                        chmod 600 sshkey/id_rsa
                        chmod 644 sshkey/id_rsa.pub
                    else
                        echo "SSH key pair already exists."
                    fi
                '''
            }
        }

        stage("Build Docker Image") {
            steps {
                sh '''
                    set -e
                    docker build -t ${IMAGE_NAME}:${TAG} ./app
                    docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage("Save Docker Image to TAR") {
            steps {
                sh '''
                    set -e
                    rm -f ${IMAGE_TAR}
                    docker save -o ${IMAGE_TAR} ${IMAGE_NAME}:${TAG}
                    ls -lh ${IMAGE_TAR}
                '''
            }
        }

        stage("Check Terraform Availability") {
            steps {
                sh '''
                    set -e
                    command -v terraform
                    terraform version
                '''
            }
        }

        stage("Terraform Apply") {
            steps {
                dir("${TF_DIR}") {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh '''
                            set -e

                            terraform init

                            terraform plan -out=tfplan \
                                -var="aws_region=${AWS_REGION}" \
                                -var="key_name=${KEY_NAME}" \
                                -var="public_key=$(cat ../../sshkey/id_rsa.pub)"

                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
        }

        stage("Get EC2 Public IP") {
            steps {
                dir("${TF_DIR}") {
                    script {
                        env.EC2_PUBLIC_IP = sh(
                            script: 'terraform output -raw public_ip',
                            returnStdout: true
                        ).trim()
                    }
                }

                echo "EC2 Public IP: ${env.EC2_PUBLIC_IP}"
            }
        }

        stage("Wait for EC2 SSH") {
            steps {
                sh '''
                    set -e
                    echo "Waiting for EC2 SSH to become available..."

                    for i in $(seq 1 60); do
                        if ssh -o StrictHostKeyChecking=no \
                               -o UserKnownHostsFile=/dev/null \
                               -o ConnectTimeout=10 \
                               -i sshkey/id_rsa \
                               ubuntu@${EC2_PUBLIC_IP} "echo READY" >/dev/null 2>&1; then
                            echo "EC2 SSH is ready."
                            exit 0
                        fi

                        echo "EC2 not ready yet, sleeping 10s..."
                        sleep 10
                    done

                    echo "EC2 SSH did not become ready in time."
                    exit 1
                '''
            }
        }

        stage("Wait for Cloud-Init") {
            steps {
                sh '''
                    set -e
                    echo "Waiting for cloud-init to finish on EC2..."

                    ssh -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -i sshkey/id_rsa \
                        ubuntu@${EC2_PUBLIC_IP} \
                        'sudo cloud-init status --wait'

                    echo "cloud-init completed."
                '''
            }
        }

        stage("Verify Docker on EC2") {
            steps {
                sh '''
                    set -e
                    ssh -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -i sshkey/id_rsa \
                        ubuntu@${EC2_PUBLIC_IP} '
                            set -e
                            echo "Checking Docker installation..."
                            docker --version || sudo docker --version
                            sudo systemctl is-active docker
                        '
                '''
            }
        }

        stage("Copy Docker Image to EC2") {
            steps {
                sh '''
                    set -e
                    scp -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -i sshkey/id_rsa \
                        ${IMAGE_TAR} \
                        ubuntu@${EC2_PUBLIC_IP}:/home/ubuntu/
                '''
            }
        }

        stage("Deploy Container on EC2") {
            steps {
                sh """
                    set -e

                    ssh -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -i sshkey/id_rsa \
                        ubuntu@${EC2_PUBLIC_IP} "
                            set -e

                            echo 'Files in /home/ubuntu:'
                            ls -lh /home/ubuntu/

                            echo 'Loading Docker image...'
                            sudo docker load -i /home/ubuntu/${IMAGE_TAR}

                            echo 'Stopping old container if exists...'
                            sudo docker stop foodexpress || true
                            sudo docker rm foodexpress || true

                            echo 'Cleaning old unused images...'
                            sudo docker image prune -f || true

                            echo 'Starting new container...'
                            sudo docker run -d \
                                --name foodexpress \
                                --restart unless-stopped \
                                -p 80:3000 \
                                ${IMAGE_NAME}:${TAG}

                            echo 'Running containers:'
                            sudo docker ps
                        "
                """
            }
        }

        stage("Verify Application") {
            steps {
                sh '''
                    set -e
                    echo "Checking app response..."
                    for i in $(seq 1 20); do
                        if curl -fsS http://${EC2_PUBLIC_IP} >/dev/null 2>&1; then
                            echo "Application is reachable."
                            exit 0
                        fi
                        echo "App not ready yet, sleeping 5s..."
                        sleep 5
                    done

                    echo "Application did not become ready in time."
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful. App is running at http://${EC2_PUBLIC_IP}"
        }
        failure {
            echo "Deployment failed."
        }
        always {
            sh '''
                rm -f ${IMAGE_TAR} || true
            '''
        }
    }
}
