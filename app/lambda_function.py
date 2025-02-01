import json
import random

def lambda_handler(event, context):
    try:
        # Simula um processo que pode ter sucesso ou falha
        input_value = event.get('input_value', 0)

        # Simula um processamento
        if input_value < 0:
            raise ValueError("Input value cannot be negative")

        # Simula uma chance de 70% de sucesso
        if random.random() < 0.7:
            result = {
                'status': 'SUCCESS',
                'message': f'Successfully processed input: {input_value}',
                'processed_value': input_value * 2
            }
        else:
            raise Exception("Random failure occurred")

        return result

    except Exception as e:
        return {
            'status': 'FAILED',
            'message': str(e),
            'error_type': type(e).__name__
        }

input = { "input_value": 10 }
result = lambda_handler(input, None)
print(json.dumps(result, indent=2))