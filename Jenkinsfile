pipeline {
    agent any

    environment {
        IMAGE = "24p1245/weather-app1"
        DOCKER_CREDS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE}:latest ."
            }
        }

        stage('Docker Login and Push') {
            steps {
                sh "echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin"
                sh "docker push ${IMAGE}:latest"
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no ubuntu@YOUR_EC2_IP \\
                'docker pull ${IMAGE}:latest && docker stop weather || true && docker rm weather || true && docker run -d -p 8080:80 --name weather ${IMAGE}:latest'
                """
            }
        }
    }
}
