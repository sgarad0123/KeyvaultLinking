#!/bin/bash

ORG="${org}"
PROJECT="${project}"
APP_ID="${app_id}"
TRACK="${trackname}"
KEYVAULT_NAME="${keyVaultName}"
SERVICE_CONNECTION_ID="${serviceConnectionId}"
PAT="${azure-devops-pat}"
SECRETS_CSV="${secretsToAdd}"
ENV="${ENV:-DEV}"

VG_NAME="${ENV}-${APP_ID}-${TRACK}-SVG"

IFS=',' read -ra SECRETS <<< "$SECRETS_CSV"
FILTER_LIST=""
for s in "${SECRETS[@]}"; do
  FILTER_LIST+="\"$s\","
done
FILTER_LIST="[${FILTER_LIST%,}]"

VG_ID=$(curl -s -u :$PAT \
"https://dev.azure.com/$ORG/$PROJECT/_apis/distributedtask/variablegroups?groupName=$VG_NAME&api-version=7.1-preview.2" |
jq -r '.value[0].id // empty')

if [[ -n "$VG_ID" ]]; then
  echo "🧹 Deleting old VG $VG_NAME"
  curl -s -X DELETE -u :$PAT \
  "https://dev.azure.com/$ORG/$PROJECT/_apis/distributedtask/variablegroups/$VG_ID?api-version=7.1-preview.2"
fi

cat > payload.json <<EOF
{
  "type": "AzureKeyVault",
  "name": "$VG_NAME",
  "providerData": {
    "serviceEndpointId": "$SERVICE_CONNECTION_ID",
    "vault": "$KEYVAULT_NAME",
    "secretsFilter": $FILTER_LIST
  },
  "variables": {}
}
EOF

echo "🔗 Linking secrets to VG $VG_NAME"

curl -s -X POST -H "Authorization: Basic $(echo -n ":$PAT" | base64)" \
  -H "Content-Type: application/json" -d @payload.json \
  "https://dev.azure.com/$ORG/$PROJECT/_apis/distributedtask/variablegroups?api-version=7.1-preview.2"
