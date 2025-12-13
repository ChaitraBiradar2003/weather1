pipeline {
    agent any

    environment {
        IMAGE = "24p1245/weather-app1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn -f springboot/springboot/pom.xml clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'cd springboot/springboot && docker build -t ${IMAGE}:latest .'
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
                      docker push ${IMAGE}:latest
                    '''
                }
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
