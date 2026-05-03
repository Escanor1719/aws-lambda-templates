#!/bin/bash

# ==============================================================================
# Script para automatizar la creación de funciones AWS Lambda
# Arquitectura: arm64 | Runtime: Python 3.13
# ==============================================================================

# 1. Validación del argumento de entrada
if [ -z "$1" ]; then
  echo "❌ Error: Debes proporcionar un nombre para la Lambda."
  echo "Uso: ./crear_lambda.sh <nombre_de_la_lambda>"
  exit 1
fi

LAMBDA_NAME=$1
# Reemplaza esto con el ARN del rol de IAM que usarán tus Lambdas por defecto
ROLE_ARN="arn:aws:iam::TU_CUENTA_ID:role/tu_rol_lambda_basico" 

echo "🚀 Iniciando la creación de la plantilla para: $LAMBDA_NAME"

# 2. Creación de la estructura de directorios
mkdir -p "$LAMBDA_NAME"
echo "✅ Directorio /$LAMBDA_NAME creado."

# 3. Generación del código base (lambda_function.py)
cat <<EOF > "$LAMBDA_NAME/lambda_function.py"
import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
EOF
echo "✅ Archivo lambda_function.py generado con la plantilla base."

# 4. Empaquetado del código
echo "📦 Empaquetando código..."
cd "$LAMBDA_NAME" || exit
zip -q -r deployment_package.zip lambda_function.py
cd ..

# 5. Creación del recurso en AWS mediante AWS CLI
echo "☁️  Desplegando en AWS (Runtime: python3.13, Arch: arm64)..."
aws lambda create-function \
    --function-name "$LAMBDA_NAME" \
    --runtime "python3.13" \
    --architectures "arm64" \
    --handler "lambda_function.lambda_handler" \
    --role "$ROLE_ARN" \
    --zip-file "fileb://$LAMBDA_NAME/deployment_package.zip" --no-cli-pager

if [ $? -eq 0 ]; then
    echo "🎉 ¡Éxito! La Lambda '$LAMBDA_NAME' ha sido creada y desplegada correctamente."
else
    echo "❌ Hubo un error al intentar crear la Lambda en AWS."
fi

# 6. Limpieza (Opcional: eliminar el .zip local para mantener limpio el directorio)
rm "$LAMBDA_NAME/deployment_package.zip"