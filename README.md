# Serverless Health Check API with CI/CD

The goal of this project is to build, configure, and automate the deployment of a simple serverless application on AWS. Created a health check endpoint that logs requests and stores them in a database, with a CI/CD pipeline to manage deployments for both staging and production environments, fully provisioned via Terraform and deployed automatically using GitHub Actions.

## Prerequisites
- An AWS account and IAM user with rights to create IAM, Lambda, API Gateway, DynamoDB, CloudWatch.
- Local toolchain:
  - Terraform v1.2+
- GitHub repo secrets (Repository > Settings > Secrets):
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION` (e.g. `us-east-1`)

## Architectural desig

### Core Components

- Amazon API Gateway (HTTP API)
- AWS Lambda (Python)
- Amazon DynamoDB
- AWS IAM
- Amazon CloudWatch Logs

Each environment (staging, prod) is isolated by naming convention and Terraform variables.

[Live Demo Link](https://www.loom.com/share/3b1a44b435724293b7be8953ed51ae27)

### Runtime Request Flow

1. _Client_: sends a GET or POST request to:

```
https://<api-id>.execute-api.<region>.amazonaws.com/health
```
2. _API Gateway_: 
- Matches the /health route
- Forwards the request using AWS_PROXY integration
3. _Lambda Function (env-health-check-function)_:
- Logs the full request event to CloudWatch Logs
- Generates a UUID
- Stores request metadata in DynamoDB (env-requests-db)
- Returns a JSON response
4. _DynamoDB_:
- Stores the request record (ID, timestamp, request payload)

### Pipeline Flow
1. Developer pushes code
- staging branch → auto deploy
- main branch → production deploy
2. GitHub Actions workflow: The GitHub action workflow contain both terraform deploy and terraform destroy.
- Configures AWS credentials (GitHub Secrets)
- Terraform deploy - deploy.yaml
    - Checks out code
    - Runs:
        - terraform fmt
        - terraform validate
        - terraform plan
        - terraform apply

- Terraform destroy - destroy.yaml
    - On GitHub console, manually trigger the destroy pipeline from the actions
    - Runs:
        - terraform int
        - terraform destroy

### Environment separation

| Aspect         | Staging                         | Production                   |
| -------------- | ------------------------------- | ---------------------------- |
| Branch         | `staging`                       | `main`                       |
| Terraform vars | `staging.tfvars`                | `prod.tfvars`                |
| Lambda         | `staging-health-check-function` | `prod-health-check-function` |
| DynamoDB       | `staging-requests-db`           | `prod-requests-db`           |
| S3 Bucket  | `serverless-health-check-api/staging/tfstate` | `serverless-health-check-api/prod/tfstate`|
| API Gateway    | `staging-health-check-api`      | `prod-health-check-api`      |
| Approval       |  None                           |  Required                   |


### Security and IAM Role
Each Lambda function has one dedicated IAM role with:
- _Allowed permissions_
    - dynamodb:PutItem → specific DynamoDB table ARN
    - logs:CreateLogGroup
    - logs:CreateLogStream
    - logs:PutLogEvents
- Denied by default
    - No read access to DynamoDB
    - No access to other AWS services
    - No wildcard write permissions
- secrets Handling
    - AWS credentials stored in GitHub Secrets
    - No credentials committed to repository


![](/svrhecheck.drawio.png)

## Setup

_Repository Structure_
.
├── .github
│   └── workflows
│       ├── deploy.yml
│       └── destroy.yml
├── lambda
│   └── lambda_function.py
├── terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── apigw.tf
│   ├── outputs.tf
│   ├── staging.tfvars
│   ├── prod.tfvars
│   ├── backend-prod.tfvars
│   └── backend-staging.tfvars
└── README.md


- Create the lambda function, run the python funtion locally using VS Code Run Button, import boto3, logging,json, os, uuid.
- Resource names follows _env-resource-name_

## How to trigger deployments

_Manual for test_
- terraform init -backend-config=backend-staging.tfvars for staging environment
- terraform init -backend-config=backend-prod.tfvars for prod environment
- terraform plan -backend-config=backend-staging.tfvars for staging environment
- terraform plan -backend-config=backend-prod.tfvars for prod environment
- terraform apply -var-file="staging.tfvars"
- terraform apply -var-file="prod.tfvars"
- terraform destroy -backend-config=backend-staging.tfvars for staging environment
- terraform destroy -backend-config=backend-prod.tfvars for prod environment

_GitHub Action CICD_
### Staging
1. Push to branch `staging` (or open a PR merging into `staging` and merge).
2. GitHub Action will automatically:
   - `terraform init`
   - `terraform plan -var-file="staging.tfvars"`
   - `terraform apply` (auto-approved)

### Production
1. Push to branch `main` (or merge PR into `main`).
2. Workflow will run and wait for **manual approval** in the `production` environment (configure environment reviewers in Settings).
3. Approve in GitHub UI → workflow will `apply` the `prod.tfvars` plan.

### Trigger Destroy CICD pipeline
Manually trigger the terraform destroy workflow in GitHub UI -> actions -> destroy.yaml

## Testing the /health endpoint

After deployment, Terraform outputs the API endpoint. You can fetch it:
- From the Actions run logs (last step runs `terraform output -json`)

Example curl (replace `<API_ENDPOINT>` with the `api_endpoint` output):
```
# GET
curl "https://nrbefv9bcj.execute-api.us-east-1.amazonaws.com/health"

# Output
{"status": "healthy", "message": "Request processed and saved.", "id": "0fb4fa88-64a1-440d-84b1-5a6d4354364b"}

```