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
               dir('springboot/springboot') {
                    sh 'docker build -t $IMAGE .'
                }
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
                 // Example: using scp & ssh to copy and run on EC2
                sh '''
                scp -i Weather-App1-Pem-Key.pem docker-compose.yml ubuntu@:51.20.76.196 /home/ubuntu/
                ssh -i Weather-App1-Pem-Key.pem ubuntu@51.20.76.196 "docker pull $IMAGE && docker-compose up -d"
                '''
            }
        }
    }
}
