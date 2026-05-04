# 🚀 AWS DevSecOps Pipeline & Infrastructure Automation
### 📋 Project Overview

This project implements a high-availability, multi-tier DevSecOps environment on AWS. It features a fully automated infrastructure provisioned with Terraform and a sophisticated Jenkins CI/CD pipeline. The architecture integrates continuous security scanning, code quality gates, and automated deployment to containerized environments.

<img width="670" height="470" alt="Untitled Diagram(1)" src="https://github.com/user-attachments/assets/4548c09e-de05-47a5-a55f-99827e98108b" />  <img width="960" height="720" alt="Untitled Diagram(2)" src="https://github.com/user-attachments/assets/ed448bf2-ad46-4419-ab7d-26f962039d01" />

### 🏗️ Architecture (AWS Cloud)

 The setup follows cloud best practices for network isolation and resource security:

* **Networking**: A custom Private VPC architecture that segments traffic into public and private subnets.

* **Security & Access**:

  * **AWS Secrets Manager**: Secure storage for credentials, preventing hardcoded secrets in the code.

  * **Security Groups**: Granular firewall rules to enforce the principle of least privilege between Jenkins and SonarQube.

  * **NAT Gateway**: Provides secure outbound internet access for private resources to download patches and dependencies.
    
  * **Load Balancing**: A Network Load Balancer (NLB) manages incoming traffic to the management tools efficiently.

* **Compute**: Dedicated instances for Jenkins (Automation) and SonarQube (Quality) located in a private subnet.

* **Storage & Registry**:

  * **Amazon S3**: Used for Terraform state management and artifact storage.

  * **Amazon ECR**: Private registry for versioned and scanned Docker images.
    
---

### 🔄 CI/CD & DevSecOps Pipeline

The workflow automates the journey from code commit to deployment, prioritizing security at every stage:

**Source Control**: Code is hosted on GitHub.

**1. Infrastructure Pipeline (GitHub Actions + Terraform)**

* **Continuous Deployment (IaC)**: Every change to the Terraform configuration triggers a GitHub Actions workflow.

* **Plan & Apply**: Automated terraform plan for code review in Pull Requests and terraform apply to provision AWS resources.

* **State Management**: Securely manages the infrastructure state in Amazon S3 to ensure consistency across the team.

**2. Application Pipeline (Jenkins)**:

* **Maven Compile & Test**: Automatic build and unit testing.

* **Quality Analysis (SonarQube)**: Static Application Security Testing (SAST) to identify bugs and code smells.

* **Dependency Check (OWASP)**: Scans for vulnerabilities in third-party libraries.

* **Continuous Deployment**:

* **Docker Build & Push**: Packaging the app into a container and pushing it to Amazon ECR.

* **Image Scan (Trivy)**: Deep scanning of Docker images for OS-level vulnerabilities.

* **Approval & Delivery**:

  * **Approval Mail**: Manual gate to authorize the final deployment.

  * **Multi-Target Deployment**: The app can be deployed to Docker Containers or Apache Tomcat servers.

---

### 🛠️ Tech Stack

* **Cloud**: AWS (VPC, S3, ECR, NLB, NAT Gateway, Secrets Manager)

* **IaC**: Terraform

* **CI/CD**: Jenkins, GitHub

* **Security & Quality**: SonarQube, OWASP Dependency-Check, Trivy

* **Build Tools**: Maven, Docker

* **App Servers**: Apache Tomcat

---

### 🧠 Key Challenges Solved

* **Network Isolation**: Configured **Jenkins** and **SonarQube** in private subnets with controlled access through a NAT Gateway.

* **DevSecOps Integration**: Merged multiple security layers (SAST, Dependency Check, Container Scan) into a single, high-speed pipeline.

* **Infrastructure as Code**: Achieved a 100% reproducible environment using **Terraform**, ensuring consistent deployments.
