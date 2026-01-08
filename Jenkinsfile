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
        withCredentials([sshUserPrivateKey(
            credentialsId: 'weather-key',
            keyFileVariable: 'Key',
            usernameVariable: 'EC2_USER'
        )]) {
            sh '''#!/bin/bash
                echo "Using key: $Key"
                echo "Using user: $EC2_USER"

                # Copy docker-compose.yml
                scp -o StrictHostKeyChecking=no \
                    -i "$Key" \
                    "${WORKSPACE}/springboot/springboot/docker-compose.yml" \
                    "$EC2_USER@13.48.5.190:/home/ubuntu/"

                # SSH and deploy
                ssh -o StrictHostKeyChecking=no -i "$Key" "$EC2_USER@13.48.5.190" 'bash -s' << 'EOF'
set -e

echo "Freeing port 8080..."
sudo fuser -k 8080/tcp || true

echo "Stopping old containers..."
docker compose down || true
docker stop $(docker ps -q) || true
docker rm $(docker ps -aq) || true

echo "Cleaning unused resources..."
docker system prune -f || true

echo "Pulling latest image..."
docker pull ssk2003/weather-app1:latest

echo "Starting application..."
cd /home/ubuntu
docker compose up -d --force-recreate --remove-orphans

echo "DEPLOYMENT SUCCESS"
EOF
            '''
        }
    }
}








        

    }
}
