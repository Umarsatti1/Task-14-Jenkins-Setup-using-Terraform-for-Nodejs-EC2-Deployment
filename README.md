# Deploying Node.js Application on EC2 Using Terraform and Jenkins   

---

## Task Description

This project implements a complete CI/CD pipeline using **Terraform**, **Jenkins**, and **Amazon EC2**. All infrastructure components including VPC networking, IAM roles, Application EC2, Jenkins EC2, and CloudWatch logging are provisioned using Terraform.

Jenkins is deployed on a **private EC2 instance without a public IP** and is accessed securely using **AWS Systems Manager (SSM) Session Manager**. The Node.js application runs on a public EC2 instance using **PM2** as a process manager and **Nginx** as a reverse proxy. The Jenkins pipeline automates source code checkout, dependency installation, testing, deployment, rollback handling, and health checks.

---

## Architecture Diagram

<p align="center">
  <img src="./diagram/Architecture Diagram.png" alt="Architecture Diagram" width="900">
</p>

---

## Project Structure

The repository is divided into application code and Terraform infrastructure code to ensure modularity and maintainability.

```bash
.
├── app.js
├── package.json
├── public/
│   └── index.html
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── terraform.tfvars
│   ├── app_ec2.sh
│   ├── jenkins_ec2.sh
│   └── modules/
│       ├── vpc/
│       ├── iam/
│       └── ec2/
└── diagram/
    └── Architecture Diagram.png
```

---

## Application Files

**app.js**
- Main Node.js application entry point.
- Uses Express to serve static content.
- Exposes a `/health` endpoint for health validation.

```bash
node app.js
```

**package.json**
- Defines application metadata and dependencies.
- Contains scripts for running and testing the app.

```bash
npm install
npm start
npm test
```

---

## Terraform Infrastructure

Terraform provisions all AWS resources using a modular architecture.

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Review Execution Plan

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

Terraform outputs critical values after provisioning:

```text
Application EC2 Private IP: 10.0.1.xxx
Jenkins EC2 Private IP:     10.0.2.xxx
Jenkins Instance ID:        i-xxxxxxxx
```

---

## Terraform Modules

### VPC Module
- Creates VPC, public and private subnets.
- Configures IGW, NAT Gateway, and route tables.
- Defines security groups for application and Jenkins EC2.

### IAM Module
- Creates EC2 IAM role and instance profile.
- Attaches policies for:
  - SSM Session Manager
  - CloudWatch logging

### EC2 Module
- Provisions Application EC2 (public subnet).
- Provisions Jenkins EC2 (private subnet).
- Executes bootstrap scripts using user data.

---

## EC2 Bootstrap Scripts

### Application EC2 (`app_ec2.sh`)
- Installs Node.js 20, PM2, Nginx, and CloudWatch Agent.
- Configures PM2 startup and Nginx reverse proxy.
- Creates rollback directories.

```bash
node -v
npm -v
pm2 status
sudo systemctl status nginx
```

### Jenkins EC2 (`jenkins_ec2.sh`)
- Installs OpenJDK 21 and Jenkins.
- Enables Jenkins service on boot.

```bash
java -version
sudo systemctl status jenkins
```

---

## Jenkins Setup

### Access Jenkins via SSM Port Forwarding

```bash
aws ssm start-session --target <JENKINS_INSTANCE_ID> --document-name AWS-StartPortForwardingSession --parameters "portNumber=8080,localPortNumber=8080"
```

Access Jenkins UI at:

```text
http://localhost:8080
```

Retrieve initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## Jenkins Pipeline Execution

The Jenkins pipeline automates the complete CI/CD workflow.

```bash
Checkout → Build → Test → Deploy → Health Check
```

### Deployment Commands (Executed Remotely on EC2)

```bash
sudo rm -rf /var/www/nodeapp_new
sudo mkdir -p /var/www/nodeapp_new
sudo chown ubuntu:ubuntu /var/www/nodeapp_new

scp -r app.js package.json public ubuntu@<EC2_IP>:/var/www/nodeapp_new/

pm2 restart nodeapp || pm2 start app.js --name nodeapp
pm2 save
```

### Health Check

```bash
curl http://<EC2_PUBLIC_IP>:3000/health
```

Expected output:

```text
HTTP/1.1 200 OK
```

---

## Validation

- Application accessible via public EC2 IP.
- `/health` endpoint returns HTTP 200.
- PM2, Nginx, and CloudWatch Agent verified running.
- Logs available in AWS CloudWatch.

---

## Clean Up

All AWS resources are removed using:

```bash
terraform destroy -auto-approve
```

This ensures no infrastructure remains active and avoids unnecessary costs.

---

## Troubleshooting

Common issues resolved during this project included:
- EC2 resource exhaustion due to unnecessary build steps.
- Missing Node.js tooling on Jenkins instance.
- Malformed SSH heredocs in pipeline scripts.
- Terraform type mismatches for security groups.
- Missing SSH key pair assignment.
