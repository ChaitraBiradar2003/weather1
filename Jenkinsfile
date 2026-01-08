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
        sh '''
            # Copy docker-compose.yml to EC2
            scp -o StrictHostKeyChecking=no -i /home/jenkins/.ssh/weather-key.pem ${WORKSPACE}/springboot/springboot/docker-compose.yml ubuntu@13.48.5.190:/home/ubuntu/

            # SSH into EC2 and deploy
            ssh -o StrictHostKeyChecking=no -i /home/jenkins/.ssh/weather-key.pem ubuntu@13.48.5.190 << EOF
                set -e

                echo "Stopping old containers..."
                docker compose down || true
                docker rm -f weather-app || true

                echo "Killing any process using port 8080..."
                sudo fuser -k 8080/tcp || true

                echo "Pulling latest Docker image..."
                docker pull ssk2003/weather-app1:latest

                echo "Starting container..."
                docker compose up -d --force-recreate --remove-orphans

                echo "Deployment finished successfully!"
EOF
        '''
    }
}





        

    }
}
