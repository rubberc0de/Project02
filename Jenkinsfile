pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'jdk-8'
        nodejs 'nodeJS'
    }

    environment {
        DOCKER_IMAGE = "java-app:${env.BUILD_ID}"
        SONAR_QUBE_SERVER = 'Sonarqube'
        ECR_URL = "926909118217.dkr.ecr.eu-south-2.amazonaws.com"
        REPO_NAME = "my_repository"
        REGION = "eu-south-2"
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
                    emailext(
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
                    }

                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due SonarQube Quality Gate: ${qg.status}"
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
                jdk 'jdk-17'
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

        stage('Docker Build') {
            steps {
                script {
                    def fullImageName = "${env.ECR_URL}/${env.REPO_NAME}:${env.BUILD_ID}"
                    sh "docker build -t ${fullImageName} ."
                }
            }
        }

        stage('Trivy scan') {
            steps {
                script {
                    def fullImageName = "${env.ECR_URL}/${env.REPO_NAME}:${env.BUILD_ID}"
                    sh  """
                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v ${HOME}/.trivycache:/root/.cache/ \
                            -v ${WORKSPACE}:/apps \
                            aquasec/trivy:latest \
                            image --format template --template "@contrib/html.tpl" \
                            --output /apps/trivy-report.html \
                            ${fullImageName}
                        """

                }
            }
        }
        stage('Security Approval & Mail') {
            steps {
                script {
                    emailext(
                        subject: "REPORT: Security Scan Results - Build #${env.BUILD_NUMBER}",
                        mimeType: 'text/html',
                        body: """
                            <!DOCTYPE html>
                            <html>
                            <body>
                            <h2>Security analysis finalized</h2>
                            <p>A visual report has been generated and attached to this email.</p>
                            <p>Approve the deployment here: <a href="${env.BUILD_URL}input">Control panel</a></p>
                            </body>
                            </html>
                        """,
                        to: '$DEFAULT_RECIPIENTS',
                        attachmentsPattern: 'trivy-report.html',
                    )
                    timeout(time: 2, unit: 'HOURS') {
                        input message: "Can we approve the deployment?",
                              ok: "Proceed"
                    }
                }
            }
        }

        stage('Docker push to ECR') {
            steps {
                script {
                    def fullImageName = "${env.ECR_URL}/${env.REPO_NAME}:${env.BUILD_ID}"
                    def latestImageName = "${env.ECR_URL}/${env.REPO_NAME}:latest"
                    sh "aws ecr get-login-password --region ${env.REGION} | docker login --username AWS --password-stdin ${env.ECR_URL}"
                    sh "docker push ${fullImageName}"
                    sh "docker tag ${fullImageName} ${latestImageName}"
                    sh "docker push ${latestImageName}"
                }
            }
            post {
                failure {
                    emailext body: "Error on the docker build & push stage, please check. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Docker Build & Push Stage",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }
        stage('Deploy to Production Container') {
            steps {
                script {
                    def containerName = "webapp"
                    def hostPort = "8083"
                    def containerPort = "8080"
                    def fullImageName = "${env.ECR_URL}/${env.REPO_NAME}:${env.BUILD_ID}"

                    sh "aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin ${env.ECR_URL}"
                    sh "docker stop ${containerName} || true"
                    sh "docker rm ${containerName} || true"
                    sh "docker pull ${fullImageName}"
                    sh "docker run -d --name ${containerName} -p ${hostPort}:${containerPort} ${fullImageName}"
                }
            }
        }
    }
}
