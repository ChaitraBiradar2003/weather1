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
            # Download docker-compose.yml from GitHub directly
            wget -O docker-compose.yml https://raw.githubusercontent.com/24p1245-ssk/Weather-App1/main/docker-compose.yml

            # Copy the file to EC2
            scp -i Weather-App1-Pem-Key.pem docker-compose.yml ubuntu@13.61.143.74:/home/ubuntu/

            # SSH into EC2 and deploy the Docker container
            ssh -i Weather-App1-Pem-Key.pem ubuntu@13.61.143.74 '
                cd /home/ubuntu
                docker-compose down || true
                docker-compose pull
                docker-compose up -d
            '
        '''
    }
}


        

    }
}
