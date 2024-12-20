# Automating-the-Deployment-of-an-E-commerce-Website-with-CI-CD---JENKINS

Project Scenario:
A tech consuling firm, is adopting a cloud architecture for its software applications. As a DevOps Engineer, your task is to design and implement a robust CI/CD pipeline using Jenkins to automate the deployment of a web application. The goal is to achieve continous integration, cotinous deployment, and ensure the scalability and reliability of the applications.

**Jenkins Server Setup:**
1. I opened up my VM and ran "sudo apt update" to update package repositories.
2. Installed JDK using the "sudo apt install default-jdk-headless" command.
3. Installed Jenkins using " wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
    sudo apt update
    sudo apt-get install jenkins" command.
4. Set up Jenkins on the web console by entering the "Administrator password".
5. Set up necessary plugins like Git, Docker etc.
6. Created the first Admin user by adding a username and strong password.
7. Logged in to the Jenkins console.

**Source code Management Repository Integration:**
1. Created a new Github repository with a README.md file and titled the repo "Jenkins-SCM".
2. Created a freestyle project titled "my-freestyle-project"
3. In the configuration part of the project I selected "Git" as the source code management.
4. I added the url of the Github repository the "Repository URL" field.
5. I added "./main" as the branch on the "Branch Specific" field.
6. In the configuration part of the project I configured the Build Triggers by selecting "Github hook trigger for GITSCM polling".
7. I edited the settings of the Repository on Github to add a "webhook."
8. Added the URL of the Jenkins web console together with /github-webhook/ to form a complete URL for the webhook.
9. Under content type I selected "application/json" then selected "Add webhook".
10. Checked the Github post test to ensure that Github is able to communicate with Jenkins.

    Jenkins Freestyle Jobs for Build and Unit Tests:
1. Selected add "new item" on Jenkins.
2. Added a new freestyle project titles "Build and Unit Tests".
3. I used "Execute shell" for the Build Steps.
4. Ran the job and it ran successfully.

**Jenkins pipeline for Web Application:**
1. Selected add "new item" on Jenkins.
2. Added a new pipline job titled "webapp"
3. I used a text editor to create a web application using Node.js
4. I installed the Node.js plugin on Jenkins. Docker-build-step, docker common and Docker pipeline
5. I also installed NPM on the Jenkins server.
6. I configured a Jenkinsfile for the webapp and added it as a pipeline script. find the script below.
   pipeline {
    agent any

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
                sh 'npm install' // For Node.js projects, "npm install" installs dependencies.
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building the application...'
                sh 'npm run build' // "npm run build" builds the project if a build script is defined in package.json.
            }
        }

        stage('Test Application') {
            steps {
                echo 'Running tests...'
                sh 'npm test' // "npm test" runs tests defined in package.json scripts.
            }
        }

        stage('Run Application') {
            steps {
                echo 'Starting the application...'
                sh 'npm start' // "npm start" starts the application using the start script in package.json.
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
7. I ran the job and verified that all the stages ran successfully.

   **Docker Image Creation and Registry push:**
   
 1. Created a simple Dockerfile. below is the Dockerfile and added it the "Jenkins-SCM" repository:
   # Use a suitable base image for your application.
   # For a Node.js application, use a Node.js base image.
   FROM node:16-alpine

   # Set the working directory inside the container.
   WORKDIR /app

  # Copy package.json and package-lock.json (if available) first for caching.
  COPY package*.json ./

  # Install application dependencies.
  RUN npm install

  # Copy the rest of the application code.
  COPY . .

  # Expose the port your application listens on.
  EXPOSE 8081

  # Define the command to start your application.
  CMD ["npm", "start"]
  
2. I installed the Docker-build-step, docker common, and Docker pipelines plugin on Jenkins.
3. I added the Jenkins user to the docker group using "sudo usermod -aG docker jenkins" command.
4. I restarted Docker and Jenkins for the configuration to take effect.
5. I created a Pipeline job titled "Docker-web-app"
6. I created a Jenkinsfile for the task, find my Jenkinsfile below:
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

7. I used "personal access token" for dockerhub login. I had to configure it as a global credential in Jenkins so that I do not have to hardcode it into the code.
8. I ran the job and it ran successfully.
9. For the code to work I had to configure a package.json file and an index.js file for the whole code to work.
10. Here is the package.json file:
     {
  "name": "example-app",
  "version": "1.0.0",
  "scripts": {
    "build": "mkdir -p dist",
    "test": "echo 'Running tests'",
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}

11. Here is the  index.js file:
const express = require('express');
const app = express();
const port = 8081;

app.get('/', (req, res) => {
  res.send('Hello from Docker!');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server listening on port ${port}`);
});


   


