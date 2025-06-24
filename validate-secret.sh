#!/bin/bash

APP_ID="${app_id}"
SECRET_NAME="${secretName}"
ENV="${ENV:-DEV}"

echo "🔍 Validating secret for environment: $ENV"

if [[ "$SECRET_NAME" =~ $APP_ID ]]; then
  echo "✅ Validation passed. '$SECRET_NAME' belongs to App ID: $APP_ID"
else
  echo "❌ Validation failed. '$SECRET_NAME' is not linked to APP ID: $APP_ID"
  exit 1
fi
