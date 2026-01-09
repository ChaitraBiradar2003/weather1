pipeline {
    agent any

    environment {
        IMAGE = "ssk2003/weather-app1"
        DOCKER_CREDS = credentials('dockerhub-creds')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                 // Use Maven wrapper from root if present, or system Maven
         sh 'mvn -f springboot/springboot/pom.xml clean package -DskipTests'
        // OR if mvnw is not in root, use:
        // sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
               dir('springboot/springboot') {
                    sh 'docker build -t $IMAGE .'
                }
            }
        }

        stage('Docker Login and Push') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh '''
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker push ssk2003/weather-app1:latest
            '''
        }
    }
}















        
stage('Deploy to EC2') {
    steps {
        withCredentials([
            sshUserPrivateKey(
                credentialsId: 'weather-key',
                keyFileVariable: 'KEY',
                usernameVariable: 'EC2_USER'
            )
        ]) {
            sh '''#!/bin/bash
set -eux

EC2_IP="13.60.90.135"
IMAGE="ssk2003/weather-app1:latest"
DEPLOY_DIR="/home/ubuntu"

echo "Copying docker-compose.yml to EC2..."
scp -o StrictHostKeyChecking=no -i "$KEY" \
"$WORKSPACE/springboot/springboot/docker-compose.yml" \
"$EC2_USER@$EC2_IP:$DEPLOY_DIR/"

echo "Deploying on EC2..."
ssh -o StrictHostKeyChecking=no -i "$KEY" "$EC2_USER@$EC2_IP" <<'EOF'
set -eux

cd /home/ubuntu

# Kill any process using port 8080
sudo fuser -k 8080/tcp || true

# Stop and remove all containers for this project
docker compose down -v --remove-orphans || true

# Pull latest image
docker pull ssk2003/weather-app1:latest

# Start containers
docker compose up -d --force-recreate

echo "Deployment successful"
EOF
'''
        }
    }
}


    }
}
