# Serverless Health Check API with CI/CD

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

Run the python funtion

```
# Output

{'statusCode': 200, 'body': 'Hello, Emmanuel Ogah!'}"
```
