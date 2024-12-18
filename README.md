#README#

What is this repository for?

	•	Quick summary: This repository contains the Infrastructure as Code (IaC) scripts for deploying an ECS Fargate service that runs a Python application. The application fetches data from an Oracle RDS database hosted in a private VPC and sends the data to Moodle via Moodle API calls. The setup uses Terraform for infrastructure provisioning and Bitbucket Pipelines for CI/CD.
	•	Version: 1.0.0


How do I get set up?

- Summary of set up:
	•	This project uses Terraform to provision infrastructure on AWS, including ECS, ECR, RDS, and related IAM roles and security groups. EventBridge is used to schedule auto execution (set to daily).
	•	The application is containerized using Docker and deployed to ECS Fargate.
	•	Terraform state is managed remotely in an S3 bucket.

- Configuration:
	•	Ensure you have the necessary AWS credentials set up (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY).
	•	Set the required environment variables such as SECRET_NAME in the Bitbucket Pipelines configuration.

- Dependencies:
	•	Terraform >= 1.3.7
	•	AWS CLI
	•	Docker
	•	Python 3.9
	•	Oracle Instant Client for Python (included in the Dockerfile)


Database configuration:
- The application connects to an Oracle RDS instance. Ensure the RDS security group allows inbound traffic on port 1521 from the ECS task’s security group.
- Database credentials are stored in AWS Secrets Manager and are accessed by the ECS task at runtime.



Deployment instructions:
- The deployment is handled through Bitbucket Pipelines:
	1.	Push changes to the master branch.
	2.	Bitbucket Pipelines will automatically plan and apply the Terraform changes.
	3.	The application will be built and deployed to ECS Fargate.
- To manually deploy:
    terraform init
    terraform plan -out=plan.out
    terraform apply plan.out