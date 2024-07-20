@echo off
cd lambda
yarn install
yarn run build
powershell Compress-Archive -Path .\dist\* -DestinationPath .\dist\lambda_function_payload.zip