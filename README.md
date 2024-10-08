# **AWS Infrastructure as Code with Terraform**

This project demonstrates a complete CI/CD pipeline setup using AWS services, provisioned and managed using Terraform. The infrastructure includes an auto-scaling group of EC2 instances behind an application load balancer, CloudWatch monitoring and logging, and automated deployment pipelines.

## **Table of Contents**

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Monitoring and Logging](#monitoring-and-logging)
- [Cleanup](#cleanup)
- [Contributing](#contributing)
- [License](#license)

## **Overview**

This project automates the deployment and scaling of web applications on AWS using Terraform. It includes:
- EC2 instances in an Auto Scaling group.
- An Application Load Balancer (ALB) to distribute traffic.
- CloudWatch for monitoring and logging.
- Automated scaling policies based on CPU utilization.

## **Architecture**

The architecture consists of:
- **VPC and Subnets**: A Virtual Private Cloud (VPC) with public and private subnets across multiple availability zones.
- **EC2 Instances**: A fleet of EC2 instances managed by an Auto Scaling group.
- **Load Balancer**: An Application Load Balancer distributing traffic to the EC2 instances.
- **CloudWatch**: Monitoring and logging setup to track the performance and health of the infrastructure.
- **IAM Roles**: Secure access control with IAM roles and policies.

## **Features**

- **Infrastructure as Code**: All resources are defined in Terraform for easy management and reproducibility.
- **Auto Scaling**: Automatically scales the number of EC2 instances based on defined policies.
- **Load Balancing**: Distributes incoming traffic evenly across multiple instances.
- **Monitoring and Alerts**: CloudWatch is configured for monitoring metrics and setting up alarms.
- **Logging**: CloudWatch Logs are enabled for centralized log collection from EC2 instances.
- **CI/CD Integration**: Compatible with CI/CD workflows for automated deployments.

## **Prerequisites**

- AWS Account with appropriate permissions.
- Terraform installed on your local machine.
- AWS CLI configured with access keys.
- Git installed for version control.

## **Getting Started**

1. **Clone the Repository**

   ```bash
   git clone https://github.com/your-repo/aws-terraform-iac.git
   cd aws-terraform-iac
   ```

2. **Configure AWS CLI**

   Make sure your AWS CLI is configured with the necessary credentials and region.

   ```bash
   aws configure
   ```

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Plan and Apply Terraform Configuration**

   - **Plan**: Review the changes Terraform will make.

     ```bash
     terraform plan
     ```

   - **Apply**: Apply the configuration to create resources.

     ```bash
     terraform apply
     ```

## **Usage**

- **Access the Application**: Once the infrastructure is up, the DNS name of the load balancer will be displayed in the output. Use this to access the webpage.

- **Scaling**: The infrastructure automatically scales based on the CPU utilization metrics.

## **Monitoring and Logging**

- **CloudWatch Metrics**: Monitor the health and performance of your instances and load balancer.
- **CloudWatch Logs**: Logs from EC2 instances are sent to CloudWatch Logs for centralized logging.

### **CloudWatch Alarm Setup**

The project includes a CloudWatch alarm for monitoring CPU utilization. The Auto Scaling group adjusts the number of instances to keep the average CPU utilization around 50%.

## **Cleanup**

To destroy all resources created by this project, run:

```bash
terraform destroy
```

This will remove all the AWS resources created by Terraform.

## **License**

This project is licensed under the MIT License.

---


