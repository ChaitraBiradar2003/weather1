pipeline {
    agent any

    environment {
        IMAGE = "24p1247/weather-app1"
        DOCKER_CREDS = credentials('docker_cred')
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
            credentialsId: 'docker_cred',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh '''
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker push 24p1247/weather-app1:latest
            '''
        }
    }
}


stage('Deploy to EC2') {
    steps {
        withCredentials([sshUserPrivateKey(
            credentialsId: 'ec2_cred',
            keyFileVariable: 'KEY',
            usernameVariable: 'EC2_USER'
        )]) {
            script {
                def EC2_IP = "13.53.38.37"
                def IMAGE = "24p1247/weather-app1:latest"
                def APP_NAME = "weather-app"

                echo "Copying docker-compose.yml to EC2..."
                sh "scp -o StrictHostKeyChecking=no -i $KEY $WORKSPACE/springboot/springboot/docker-compose.yml $EC2_USER@$EC2_IP:/home/ubuntu/weather1/"

                echo "Stopping old containers..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'cd /home/ubuntu/weather1 && docker-compose down || true'"

                echo "Pulling new Docker image..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'docker pull $IMAGE'"

                echo "Starting containers..."
                sh "ssh -o StrictHostKeyChecking=no -i $KEY $EC2_USER@$EC2_IP 'cd /home/ubuntu/weather1 && docker-compose up -d --force-recreate'"

                echo "Deployment successful!"
            }
        }
    }
}








        

    }
}
