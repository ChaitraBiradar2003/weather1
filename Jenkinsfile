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
                    keyFileVariable: 'KEY_FILE',
                    usernameVariable: 'USER'
                )]) {
                    sh '''
                        echo "Copying docker-compose.yml to EC2..."
                        scp -o StrictHostKeyChecking=no -i $KEY_FILE ${WORKSPACE}/springboot/springboot/docker-compose.yml $USER@13.48.5.190:/home/ubuntu/

                        echo "Deploying app on EC2..."
                        ssh -o StrictHostKeyChecking=no -i $KEY_FILE $USER@13.48.5.190 << EOF
                            set -e
                            echo "Stopping and removing old containers..."
                            docker compose down || true
                            docker rm -f weather-app || true

                            echo "Freeing port 8080 if in use..."
                            fuser -k 8080/tcp || true

                            echo "Pulling latest Docker image..."
                            docker pull $IMAGE:latest

                            echo "Starting new container..."
                            docker compose up -d --force-recreate --remove-orphans

                            echo "Deployment complete!"
EOF
                    '''
                }
            }
        }





        

    }
}
