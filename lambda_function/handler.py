import boto3
import logging
import time

def lambda_handler(event, context):
    # Initialize the Boto3 clients for SSM and CloudWatch Logs
    ssm_client = boto3.client('ssm')
    logs_client = boto3.client('logs')
    parameter_name = '/app-7'
    log_group_name = 'app-7'
    log_stream_name = 'app-7-lambda-log-stream'
    try:
        # Read the parameter from SSM Parameter Store
        response = ssm_client.get_parameter(Name=parameter_name, WithDecryption=True)
        parameter_value = response['Parameter']['Value']
        
        # Write the parameter value to CloudWatch Logs
        logs_client.create_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)
        logs_client.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            logEvents=[
                {
                    'timestamp': int(round(time.time() * 1000)),
                    'message': f"Parameter value read from SSM Parameter Store: {parameter_value}"
                }
            ]
        )
        logging.info(f"Parameter value '{parameter_value}' written to CloudWatch Logs group '{log_group_name}'")
    
    except Exception as e:
        logging.error(f"An error occurred: {e}")