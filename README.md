# Exemplo em python, lambda e stepfunction
- esse projeto simula a chamada de um gwt que executa um lambda
- que em seguida executar uma stepfunction
- que possui uma step que chame outro lambda
````
Cliente -> API Gateway -> Lambda -> Step Function****
````
- gwt
````
O API Gateway está funcionando como uma camada de API HTTP
Ele encaminha as requisições diretamente para a Lambda
Não há cache ou balanceamento de carga
É uma integração direta (AWS_PROXY)
````
- curl
```commandline
curl -X POST https://seu-gwt/prod/trigger \
  -H 'Content-Type: application/json' \
  -d '{"input_value": 10}'
```
- obs: esse projeto não tem por objetivo ser complexo, e sim demonstrar a integração
- para gerar o arquivo zip
```
python build.py
```

# Detalhes 
```
Ah! Agora vou detalhar os tipos de estados (states) disponíveis nas Step Functions. Vou criar um diagrama e depois explicar cada um.



1. **Task State**:
   ```json
   {
     "Type": "Task",
     "Resource": "arn:aws:lambda:REGION:ACCOUNT:function:FUNCTION_NAME",
     "Next": "NextState",
     "Retry": [...],
     "Catch": [...]
   }
   ```
   - Executa um trabalho específico (Lambda, ECS, etc)
   - Pode ter retry e catch para tratamento de erros
   - Suporta timeouts e heartbeats

2. **Choice State**:
   ```json
   {
     "Type": "Choice",
     "Choices": [
       {
         "Variable": "$.value",
         "NumericEquals": 1,
         "Next": "State1"
       },
       {
         "Variable": "$.value",
         "NumericGreaterThan": 1,
         "Next": "State2"
       }
     ],
     "Default": "DefaultState"
   }
   ```
   - Implementa branching condicional
   - Suporta múltiplas condições
   - Permite comparações numéricas, strings e booleanas
   - Requer um estado default

3. **Parallel State**:
   ```json
   {
     "Type": "Parallel",
     "Branches": [
       {
         "StartAt": "Branch1State1",
         "States": {...}
       },
       {
         "StartAt": "Branch2State1",
         "States": {...}
       }
     ],
     "Next": "NextState"
   }
   ```
   - Executa branches em paralelo
   - Cada branch tem seu próprio fluxo
   - Aguarda todas as branches completarem
   - Pode ter tratamento de erro por branch

4. **Map State**:
   ```json
   {
     "Type": "Map",
     "InputPath": "$.items",
     "ItemProcessor": {
       "ProcessorConfig": {
         "Mode": "INLINE"
       },
       "StartAt": "ProcessItem",
       "States": {...}
     },
     "Next": "NextState"
   }
   ```
   - Itera sobre uma coleção de itens
   - Pode processar itens em paralelo
   - Suporta processamento inline ou distribuído
   - Controle de concorrência

5. **Wait State**:
   ```json
   {
     "Type": "Wait",
     "Seconds": 10,
     "Next": "NextState"
   }
   ```
   - Pausa a execução por um tempo determinado
   - Pode usar timestamp ou duração
   - Útil para delays e polling

6. **Pass State**:
   ```json
   {
     "Type": "Pass",
     "Result": {
       "key": "value"
     },
     "Next": "NextState"
   }
   ```
   - Passa dados sem executar trabalho
   - Pode transformar o input
   - Útil para testes e mockups

7. **Succeed/Fail States**:
   ```json
   {
     "Type": "Succeed"
   }
   ```
   ```json
   {
     "Type": "Fail",
     "Error": "ErrorCode",
     "Cause": "Error message"
   }
   ```
   - Estados terminais
   - Succeed indica sucesso
   - Fail indica falha com causa

Características Comuns:
- Todos os estados podem ter:
  - InputPath
  - OutputPath
  - ResultPath
  - Next (exceto estados terminais)
  - Comment
  - TimeoutSeconds
  - Retry/Catch (quando aplicável)

Casos de Uso Típicos:
- **Choice**: Routing baseado em condições
- **Parallel**: Processamento concorrente
- **Map**: Processamento de arrays/listas
- **Task**: Execução de trabalho
- **Wait**: Delays e throttling
- **Pass**: Transformação de dados
- **Succeed/Fail**: Término do fluxo
```
