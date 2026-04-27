pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'jdk-8'
        nodejs 'nodeJS'
    }

    environment {
        DOCKER_CREDS = credentials('docker-token')
        DOCKER_IMAGE = "java-app:${env.BUILD_ID}"
        SONAR_QUBE_SERVER = 'Sonarqube'
    }

    stages {
        stage('Build the app') { 
            steps {
                echo 'Building application with maven...'
                dir('webapp') {
                sh 'mvn clean package -DskipTests'
                }
            }

        post {
            failure {
                emailext (
                        body: "Build compilation failed. Check the logs and resolve the issue before fixing the pipeline",
                        subject: "Error: Java application failed on build stage",
                        to: '$DEFAULT_RECIPIENTS',
                        )
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    def jdk17 = tool name: 'jdk-17'
                    withEnv(["JAVA_HOME=${jdk17}", "PATH+JAVA=${jdk17}/bin"]) {
                        withSonarQubeEnv("${SONAR_QUBE_SERVER}") {
                            dir('webapp') {
                                sh 'mvn sonar:sonar'
                    }
                }
                timeout(time: 5, unit: 'MINUTES') {
                def qg = waitForQualityGate() 
                if (qg.status != 'OK') {
                    error "Pipeline aborted due SonarQube Quality Gate: ${qg.status}"
                    }
                }
            }
        }
    }
            post {
                failure {
                    emailext body: "Application did not pass Sonarqube quality checks, please fix the vulnerabilities before trying again. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Quality Gate / Test Stage",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }
                stage('OWASP Dependency Check') {
                    tools {
        jdk "jdk-17"
    }
            steps {
                withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_KEY')]) {
                    dependencyCheck(
                        additionalArguments: "--nvdApiKey ${NVD_KEY} --scan ./ --format HTML --format XML", 
                        odcInstallation: 'OWASP'
                    )
                }
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
            post {
                failure {
                    emailext body: "Critical vulnerabilities found on the dependancies of the app. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Security Scan (OWASP)",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage ('Build docker image') {
            steps {
                script 
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}