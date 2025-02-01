import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    step_functions = boto3.client('stepfunctions')

    try:
        state_machine_arn = "arn:aws:states:us-east-1:711387127324:stateMachine:example_state_machine"
        logger.info(f"Step Function ARN: {state_machine_arn}")

        step_function_input = {
            'input_value': event.get('input_value', 10)
        }
        logger.info(f"Input para Step Function: {step_function_input}")

        # Verifica se a Step Function existe
        try:
            step_functions.describe_state_machine(
                stateMachineArn=state_machine_arn
            )
        except Exception as e:
            logger.error(f"Erro ao verificar Step Function: {str(e)}")
            raise Exception(f"Step Function não encontrada ou sem permissão: {str(e)}")

        response = step_functions.start_execution(
            stateMachineArn=state_machine_arn,
            input=json.dumps(step_function_input)
        )

        logger.info(f"Step Function iniciada: {response}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Step Function iniciada com sucesso',
                'executionArn': response['executionArn'],
                'input': step_function_input
            })
        }

    except Exception as e:
        logger.error(f"Erro: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'step_function_arn': os.environ.get('STEP_FUNCTION_ARN', 'NOT_FOUND')
            })
        }