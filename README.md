# Splunk AWS Terraform Deployment

This project automates the provisioning of AWS infrastructure to deploy and connect Splunk with AWS using Terraform.

## Features

- Creates a secure VPC environment
- Deploys an EC2 instance with Splunk Universal Forwarder or Splunk Enterprise
- Configures necessary IAM roles and security groups
- Uses AWS KMS for encryption
- Manages infrastructure state via Terraform

## Prerequisites

- Terraform >= 1.4
- AWS CLI configured (`aws configure`)
- Valid AWS credentials
- SSH key pair (e.g. `splunk-connect.pem`)
- Splunk AMI or installer ready (depending on your deployment)

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/scarecrowG59/splunk_aws_terraform.git
   cd splunk_aws_terraform
Initialize Terraform:

bash
Копировать
Редактировать
terraform init
Apply the configuration:

bash
Копировать
Редактировать
terraform apply
After provisioning, note the public IP of the EC2 instance and connect:

bash
Копировать
Редактировать
ssh -i splunk-connect.pem ec2-user@<public-ip>

- Cleanup
To destroy the infrastructure and avoid AWS charges:

bash
Копировать
Редактировать
terraform destroy

 - Files
File	Description
main.tf	Terraform configuration
terraform.tfstate	Infrastructure state
access_key.txt	(Optional) AWS key backup
.terraform.lock.hcl	Provider lock file
splunk-connect.pem	SSH private key (DO NOT SHARE)

- Security
This deployment uses AWS KMS for data encryption and restricts SSH access to your current IP.

