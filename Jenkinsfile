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
            sh '''
            #!/bin/bash
            set -euxo pipefail

            EC2_IP="13.48.5.190"
            IMAGE="ssk2003/weather-app1:latest"
            APP_NAME="weather-app"

            echo "Copying docker-compose.yml to EC2..."
            scp -o StrictHostKeyChecking=no -i "$KEY" \
              "$WORKSPACE/springboot/springboot/docker-compose.yml" \
              "$EC2_USER@$EC2_IP:/home/ubuntu/"

            echo "Deploying on EC2..."
            ssh -o StrictHostKeyChecking=no -i "$KEY" "$EC2_USER@$EC2_IP" << EOF
            set -euxo pipefail

            sudo fuser -k 8080/tcp || true

            docker compose down || true
            docker rm -f ${APP_NAME} || true

            docker pull ${IMAGE}
            docker compose up -d --force-recreate

            echo "Deployment successful"
            EOF
            '''
        }
    }
}










        

    }
}
