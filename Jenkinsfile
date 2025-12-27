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
        withCredentials([sshUserPrivateKey(credentialsId: 'weather-key', 
                                            keyFileVariable: 'KEY_FILE', 
                                            usernameVariable: 'USER')]) {
            sh '''
                # Copy docker-compose.yml to EC2
                scp -o StrictHostKeyChecking=no -i $KEY_FILE ${WORKSPACE}/springboot/springboot/docker-compose.yml $USER@13.61.195.242:/home/ubuntu/

                # SSH into EC2 and run Docker commands
                ssh -o StrictHostKeyChecking=no -i $KEY_FILE $USER@13.61.195.242 << 'EOF'
                    docker pull ssk2003/weather-app1:latest
                    docker compose down || true
                    docker compose up -d
EOF
            '''
        }
    }
}





        

    }
}
