# AWS Cloud Resume Challenge (CRC) Terraform Deployment

This repository contains the Terraform code to automate the deployment of all the services required for the AWS Cloud Resume Challenge (CRC). The services include S3 buckets, CloudFront distribution, Route 53, Lambda function, REST API using Amazon API Gateway, and the necessary IAM roles.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

The AWS Cloud Resume Challenge (CRC) is a multi-faceted project aimed at showcasing your skills in various AWS services, and Forrest Brazeal recommends using Terraform, I found it really smart and helpfull. This repository automates the deployment of the following AWS services:

- S3 Buckets: For hosting the static website and storing any additional resources.
- CloudFront: To distribute the website content globally with low latency.
- Route 53: For DNS management 
- Lambda Function: For updating website visitor count and store it in DynamoDB
- REST API (API Gateway): To create and manage APIs for the Lambda function.
- IAM Roles: To grant the necessary permissions to various AWS services.
- DynamoDB: To store and retrieve data (visitor count)required by the application.


## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- An AWS account with the necessary permissions to create the mentioned services.
- Domain name registered in Route 53 (if using a custom domain).

## Setup

1. **Clone the Repository**

   ```sh
   git clone https://github.com/amanuelararso/Terraform-implemnt-for-CRC.git
   cd Terraform-implemnt-for-CRC
2. **terraform initilization**
   ```sh
   terraform init
<img width="1437" alt="Screen Shot 2024-06-27 at 6 35 44 PM" src="https://github.com/amanuelararso/Terraform-implemnt-for-CRC/assets/26092925/11b55b07-3bcf-48ee-9cae-4647d660ae5f">

3. **Deploy**
   ```sh
   terraform apply
<img width="1437" alt="Screen Shot 2024-06-27 at 6 37 11 PM" src="https://github.com/amanuelararso/Terraform-implemnt-for-CRC/assets/26092925/c5a661c3-8bb2-4f7d-8a6d-d573975e7980">

4. **Verify the Deployment**

After the deployment is complete, verify the services are running as expected. Visit your CloudFront URL or custom domain to see your resume.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
