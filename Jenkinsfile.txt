pipeline {
agent any
environment {
IMAGE = "YOUR_DOCKERHUB_USERNAME/weather-app" // change this
DOCKER_CREDS = credentials('dockerhub-creds')
}
stages {
stage('Checkout') {
steps { checkout scm }
}
stage('Build') {
steps {
sh 'mvn -B clean package -DskipTests'
}
}
stage('Docker Build') {
steps {
sh "docker build -t ${IMAGE}:latest ."
}
}
stage('Docker Login and Push') {
steps {
sh '''
echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --passwordstdin
docker push ${IMAGE}:latest
'''
}
}
stage('Deploy to EC2') {
steps {
sshagent(['ec2-ssh-key']) {
sh '''
ssh -o StrictHostKeyChecking=no ec2-user@EC2_PUBLIC_IP
"docker pull ${IMAGE}:latest &&
docker stop weather || true &&
docker rm weather || true &&
docker run -d -p 8080:8080 --name weather ${IMAGE}:latest"
'''
}
}
}
}
}
5
