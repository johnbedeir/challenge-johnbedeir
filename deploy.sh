#!/bin/bash

#Variables

ecr="aws_ecr_repository.ecr_repo"
workflow_id=$(curl -s https://api.github.com/repos/johnbedeir/challenge-johnbedeir/actions/workflows | grep -o '"id": [0-9]*' | cut -d' ' -f2 | tail -n1)
username="johnbedeir"
reponame="challenge-johnbedeir"
github_token=$(cat github_token.txt)
branch="dev"
s3="tfstate-comforte-prod"
s3_dir="terraform-state"
tfstate_name="terraform.tfstate"
region="eu-central-1"
ingress_url=$(kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

#End_Of_Variables

#Terraform apply the ECR
cd terraform && \
terraform init && \
terraform apply -target=$ecr -auto-approve

#Manually trigger the workflow to Build and Push Docker image to the created ECR
curl -X POST https://api.github.com/repos/$username/$reponame/actions/workflows/$workflow_id/dispatches \
-H "Accept: application/vnd.github.v3+json" \
-H "Authorization: Bearer $github_token" \
-d '{"ref": "$branch", "inputs": {}}'

#Terraform apply EKS, S3 and deploy the Application
cd terraform && \
terraform apply -auto-approve

#Wait for all the pods to be up and running
sleep 60s

#Push the terraform state file to the created S3
aws s3 cp $tfstate_name s3://$s3/$s3_dir/$tfstate_name --region $region

#Reveal the ingress URL
echo $ingress_url
