pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'jdk-8'
    }

    environment {
        DOCKER_CREDS = credentials('docker-token')
        DOCKER_IMAGE = "java-app:${env.BUILD_ID}"
        SONAR_QUBE_SERVER = 'sonar-scanner'
    }

    stages {
        stage('Build the app') { 
            steps {
                echo 'Building application with maven...'
                sh 'mvn clean package -DskipTests'
            }

        post {
            failure {
                emailext body: "Build compilation failed. Check the logs and resolve the issue before fixing the pipeline"
                        subject: "Error: Java application failed on build stage"
                        to: '$DEFAULT_RECIPIENTS'
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Testing the application...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}