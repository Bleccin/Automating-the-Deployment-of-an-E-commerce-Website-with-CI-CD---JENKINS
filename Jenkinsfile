pipeline {
    agent any

    environment {
        IMAGE_NAME = "bleccin/my-web-app" 
        
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the code...'
                git branch: 'main', url: 'https://github.com/Bleccin/Jenkins-SCM.git' 
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'npm install'
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building the application...'
                sh 'npm run build'
            }
        }

        stage('Test Application') {
            steps {
                echo 'Running tests...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker image...'
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo 'Running the Docker container...'
                sh "docker run -d -p 9090:8081 ${IMAGE_NAME}" // Host port 9090, container port 8081
                echo 'Sleeping for 10 seconds to allow the application to start...'
                sleep 30
                sh "curl localhost:9090" // Test on port 9090
            }
        }
        stage('checkout'){
            steps {
                git branch: 'main', url: 'https://github.com/Bleccin/Jenkins-SCM.git' 
                script {
                    println("Current branch: ${env.BRANCH_NAME}") // Print the branch name
                    sh 'git branch' // Also print the git branch output
                }
            }
        }

        stage('Push Docker Image') {
          
            steps {
                echo 'Pushing the Docker image to registry...'
                withCredentials([string(credentialsId: 'dockerhub-pat', variable: 'DOCKERHUB_PAT')]) {
                    sh "docker login -u bleccin -p ${DOCKERHUB_PAT}" // Use PAT
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
            sh "docker stop \$(docker ps -q)" // Stop all running containers
            sh "docker rm \$(docker ps -aq)" // Remove all stopped containers
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
