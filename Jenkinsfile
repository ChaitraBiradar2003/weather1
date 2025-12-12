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
                sh "docker build -t ${IMAGE}:latest springboot/springboot"
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
                sh '''
                ssh -o StrictHostKeyChecking=no -i /home/ubuntu/Weather-App1-Pem-Key.pem ubuntu@13.48.55.161 "
                    docker pull 24p1245/weather-app1:latest &&
                    docker stop weather-app1 || true &&
                    docker rm weather-app1 || true &&
                    docker run -d -p 8080:8080 --name weather-app1 24p1245/weather-app1:latest
                "
                '''
            }
        }
    }
}
