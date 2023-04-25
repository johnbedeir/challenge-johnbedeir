# Challenge-JohnBedeir

**Description:** This project is built with Terraform that deploys a simple Python web page application using Flask and connects to a MySQL database where you can add data into the database and it appears on the webpage. The application is deployed on a scalable EKS cluster with minimum one node and maximum three nodes, along with other resources like ECR, S3 bucket, MySQL database, and nginx-ingress.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Deployment](#deployment)
- [GitOps](#gitops)
- [Built With](#built-with)
- [The Reasons for Technology Stack Selection](#the-reasons-for-technology-stack-selection)

## Getting Started

To get started with this project, you'll need to set up the required resources and configure your environment.

### Prerequisites

Make sure you have the following installed:

- AWS CLI
- Terraform
- Docker
- kubectl

You'll also need an AWS account and appropriate credentials.

### Installation

To run this application locally, run the following command:

```
docker-compose up --build
```

This will build the existing Dockerfile, start the application and make it available on http://localhost:5000 and run MySQL database on PORT:3306.

### Usage

To use the application, you can connect to the database using any application, personally I am using [Beekeeper Studio](https://www.beekeeperstudio.io/), use the following QUERY:

```
CREATE DATABASE IF NOT EXISTS myapp_db;
USE myapp_db;

CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO items (name) VALUES ('Python');
INSERT INTO items (name) VALUES ('GoLang');
INSERT INTO items (name) VALUES ('PHP');
```

This will create a Database, Table and Insert the data that will be viewed by the application.

## Deployment

#### Add the following in your GitHub Secrets:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

`NOTE: Make sure you disable the` **backend.tf** `while you run the first deployment`

### 1. Create the ECR:

```
cd terraform
terraform -target=aws_ecr_repository.ecr_repo -auto-approve
```

### 2. Run the CI Workflow:

`NOTE: To Run this command make sure you create a github access token and add it in a file that will be ignored by git also update the variables in the script`

```
curl -X POST https://api.github.com/repos/$username/$reponame/actions/workflows/$workflow_id/dispatches \
-H "Accept: application/vnd.github.v3+json" \
-H "Authorization: Bearer $github_token" \
-d '{"ref": "$branch", "inputs": {}}'
```

### 3. Create EKS and Deploy the App:

```
cd terraform
terraform apply -auto-approve
```

This will create an EKS cluster, an S3 bucket to store the Terraform state file, Deploy the Application, MySQL database, and an nginx-ingress controller with the following domain:

```
comforte.johnydev.com
```

### 4. Cluster Info:

Update your **Kube Config**

```
aws eks update-kubeconfig --region $region --name $cluster_name
```

Reveal the **Ingress URL**

```
kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

This will display the hostname of the nginx-ingress controller, where you can access your application with your domain.

`NOTE: You will need to add this URL in CNAME record for your domain`

## GitOps

### Using GitHub Actions Workflow

Finally, to be able to run the CD Workflow, you need to do the following:

`NOTE: Make sure the **backend.tf** is not commented`

```
terraform init
```

When you do that you will be asked to switch your **tfstate** file from **local** state to the **s3**

Now you can run the **cd.yml** which will fetch the **tfstate** from the **s3**

`NOTE: The CD workflow can be triggered manually, on push to the main branch or on a new release`

### Another option by using ArgoCD:

`This option is working but it is disabled since we are using GitHub Actions for CD`

You can check the code in **argo.tf** which will deploy ArgoCD

## Built With

- Flask - Python web framework
- MySQL - relational database management system
- Terraform - infrastructure as code tool
- AWS - cloud computing platform
- GitHub Actions - continuous integration and delivery platform

## The Reasons for Technology Stack Selection

Beside that I have the most experience in those tools

- Flask: For its simplicity and Faster development for smaller projects, the alternative approach is by using Django
- MySQL: It is one of the most popular open-source databases, which ensures a large and active community, another approach I could use MongoDB, I have similar experience in
- Terraform: as the IaC tool for its ability to manage and provision cloud resources in a declarative and version-controlled manner. With its support for multiple cloud providers, another approach I could use Pulumi but I have less experience in.
- AWS: Because of its comprehensive range of services, global infrastructure, and strong support for scalability and security.
- GitHub Actions: This was chosen as the continuous integration and continuous delivery (CI/CD) platform for its native integration with GitHub repositories and ease of use, another alternatives I could use Jenkins or Azure DevOps (similar experience)
