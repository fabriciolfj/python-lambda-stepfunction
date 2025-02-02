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