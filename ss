pipeline {
    agent any

    tools {
        maven 'maven-3.9' // Reemplaza por tu nombre configurado
        jdk 'jdk-17'      // Reemplaza por tu nombre configurado
    }

    environment {
        // Configura estas variables en Jenkins -> Credentials
        DOCKER_HUB_USER = 'tu_usuario'
        DOCKER_IMAGE = "mi-app-java:${env.BUILD_ID}"
        SONAR_QUBE_SERVER = 'SonarQube' // Nombre en configuración global
    }

    stages {
        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
            post {
                failure {
                    emailext body: "Fallo en la compilación Maven. Revisar logs del build #${env.BUILD_NUMBER}",
                             subject: "Error: Build Stage",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage('Test & SonarQube') {
            steps {
                withSonarQubeEnv("${SONAR_QUBE_SERVER}") {
                    sh 'mvn sonar:sonar'
                }
            }
            post {
                failure {
                    emailext body: "La aplicación no pasó el análisis de calidad en SonarQube. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Quality Gate / Test Stage",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'Default'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
            post {
                failure {
                    emailext body: "Se encontraron vulnerabilidades críticas en las dependencias. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Security Scan (OWASP)",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}")
                }
            }
            post {
                failure {
                    emailext body: "Error al empaquetar la imagen Docker. Build #${env.BUILD_NUMBER}",
                             subject: "Error: Docker Build Stage",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                // Escanea la imagen buscando vulnerabilidades críticas
                sh "trivy image --severity CRITICAL --exit-code 1 ${DOCKER_IMAGE}"
            }
            post {
                failure {
                    emailext body: "La imagen Docker contiene vulnerabilidades críticas (Trivy). Build #${env.BUILD_NUMBER}",
                             subject: "Error: Image Security Scan",
                             to: '$DEFAULT_RECIPIENTS'
                }
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo 'Desplegando WAR en Tomcat...'
                // Ejemplo usando el plugin de Deploy to Container o copiado directo
                deploy artifacts: 'target/*.war', contextPath: 'mi-app', 
                       war: '**/*.war', credentialsId: 'tomcat-credentials', 
                       serverHandler: [url: 'http://tu-servidor-tomcat:8080']
            }
        }
    }

    post {
        success {
            emailext body: "¡Felicidades! El pipeline terminó con éxito. La imagen ${DOCKER_IMAGE} ha sido desplegada en Tomcat.",
                     subject: "SUCCESS: Pipeline Finalizado",
                     to: '$DEFAULT_RECIPIENTS'
        }
        always {
            cleanWs()
        }
    }
}