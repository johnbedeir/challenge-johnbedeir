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

To deploy this project, you can run the script **deploy.sh** that will do the following:

First, run Terraform to create the ECR repository:

```
terraform -target=aws_ecr_repository.ecr_repo -auto-approve
```

This will create an ECR repository where you can push the Docker image.

Next, trigger the Github Actions workflow to build and push the Docker image to the ECR using the following command:

`NOTE: Make sure you create a github access token and add it in a file that will be ignored by git also update the variables in the script`

```
curl -X POST https://api.github.com/repos/$username/$reponame/actions/workflows/$workflow_id/dispatches \
-H "Accept: application/vnd.github.v3+json" \
-H "Authorization: Bearer $github_token" \
-d '{"ref": "$branch", "inputs": {}}'
```

After the Docker image has been pushed, the script will run Terraform to create the remaining resources:

```
terraform apply -auto-approve
```

This will create an EKS cluster, an S3 bucket to store the Terraform state file, Deploy the Application, MySQL database, and an nginx-ingress controller with the following domain:

```
comforte.johnydev.com
```

Wait for at least 60 seconds to allow all the resources to be created and configured.

Next, push the Terraform state file to the S3 bucket:

```
aws s3 cp $tfstate_name s3://$s3/$s3_dir/$tfstate_name --region $region
```

Reveal the ingress URL:

```
kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

This will display the hostname of the nginx-ingress controller, where you can access your application with your domain.

`NOTE: You will need to add this URL in CNAME record for your domain`

## GitOps

Finally, to be able to run the CI-CD Workflow, you need to add the following in your GitHub Secrets:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- S3_BUCKET_NAME

## Built With

- Flask - Python web framework
- MySQL - relational database management system
- Terraform - infrastructure as code tool
- AWS - cloud computing platform
- GitHub Actions - continuous integration and delivery platform
