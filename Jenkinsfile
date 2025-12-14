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
        // Ensure the PEM file has correct permissions
        sh 'chmod 600 Weather-App1-Pem-Key.pem'

        // Copy docker-compose.yml to EC2
        sh '''
        scp -o StrictHostKeyChecking=no -i Weather-App1-Pem-Key.pem \
        docker-compose.yml ubuntu@13.61.143.74:/home/ubuntu/
        '''

        // Optional: run docker-compose on EC2
        sh '''
        ssh -o StrictHostKeyChecking=no -i Weather-App1-Pem-Key.pem ubuntu@13.61.143.74 \
        'cd /home/ubuntu && docker-compose up -d'
        '''
    }
}

        

    }
}
