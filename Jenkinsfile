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
        withCredentials([sshUserPrivateKey(credentialsId: 'weather-key', keyFileVariable: 'KEY', usernameVariable: 'EC2_USER')]) {
            script {
                def EC2_IP = "13.60.90.135"
                def IMAGE = "ssk2003/weather-app1:latest"
                def APP_NAME = "weather-app"
                
                echo "Copying docker-compose.yml to EC2..."
                sh "scp -o StrictHostKeyChecking=no -i $KEY $WORKSPACE/springboot/springboot/docker-compose.yml $EC2_USER@$EC2_IP:/home/ubuntu/"

                echo "Killing old process on port 8080..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'sudo fuser -k 8080/tcp || true'"

                echo "Stopping old containers..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'docker compose down || true'"

                echo "Removing old container..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'docker rm -f $APP_NAME || true'"

                echo "Pulling new Docker image..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'docker pull $IMAGE'"

                echo "Starting container..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'docker compose up -d --force-recreate'"

                echo "Deployment successful!"
            }
        }
    }
}












        

    }
}
