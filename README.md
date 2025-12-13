# Serverless Health Check API with CI/CD

The goal of this project is to build, configure, and automate the deployment of a simple serverless application on AWS. Created a health check endpoint that logs requests and stores them in a database, with a CI/CD pipeline to manage deployments for both staging and production environments, fully provisioned via Terraform and deployed automatically using GitHub Actions.

## Architectural desig

### Core Components

- Amazon API Gateway (HTTP API)
- AWS Lambda (Python)
- Amazon DynamoDB
- AWS IAM
- Amazon CloudWatch Logs

Each environment (staging, prod) is isolated by naming convention and Terraform variables.

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








create hello lambda funtion using Python

```
# Hello lambda function
def lambda_handler(event, context):
    name = event.get("name", "World")
    message = f"Hello, {name}!"

    return {
        "statusCode": 200,
        "body": message
    }

# Run the funtion locally for testing
if __name__ == "__main__":
    test_event = {"name": "Emmanuel Ogah"} 
    result = lambda_handler(test_event, None)
    print(result)
```

Run the python funtion locally using VS Code Run Button
- Click the “Run Python File” button in the top right corner.

```
# Output

{'statusCode': 200, 'body': 'Hello, Emmanuel Ogah!'}"
```

- Create the terraform folder structure

- Deploy with: terraform init then terraform apply -var-file="staging.tfvars" (or prod.tfvars)


endpoint - https://nrbefv9bcj.execute-api.us-east-1.amazonaws.com/health



terraform init -backend-config=backend-staging.tfvars for staging environment

terraform init -backend-config=backend-prod.tfvars for prod environment
