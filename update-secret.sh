#!/bin/bash

KEY_VAULT_NAME="${keyVaultName}"
SECRET_NAME="${secretName}"
NEW_SECRET_VALUE="${secretValue}"
ENV="${ENV:-DEV}"

echo "🔧 Updating secret '$SECRET_NAME' in Key Vault: $KEY_VAULT_NAME"

OLDER_VERSIONS=$(az keyvault secret list-versions --vault-name "$KEY_VAULT_NAME" --name "$SECRET_NAME" --query "[?attributes.enabled==\`true\`].id" -o tsv)

az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "$SECRET_NAME" --value "$NEW_SECRET_VALUE"

if [[ -n "$OLDER_VERSIONS" ]]; then
  for version in $OLDER_VERSIONS; do
    az keyvault secret set-attributes --id "$version" --enabled false
    echo "🔒 Disabled old version: $version"
  done
else
  echo "ℹ️ No previous versions found to disable."
fi

echo "✅ Secret updated for $ENV."
