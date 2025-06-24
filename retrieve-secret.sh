#!/bin/bash

KEY_VAULT_NAME="${keyVaultName}"
SECRET_NAME="${secretName}"
ENV="${ENV:-DEV}"

echo "🔍 Retrieving secret '$SECRET_NAME' from Key Vault: $KEY_VAULT_NAME"

VALUE=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "$SECRET_NAME" --query value -o tsv)

if [[ -z "$VALUE" ]]; then
  echo "⚠️ Secret not found: $SECRET_NAME"
else
  echo "📢 Secret Value: $VALUE"
  echo "✅ Successfully retrieved secret for $ENV"
fi
