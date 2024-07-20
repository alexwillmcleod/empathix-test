#!/bin/bash
cd lambda
yarn install
yarn run build
zip -r dist/lambda_function_payload.zip dist/*