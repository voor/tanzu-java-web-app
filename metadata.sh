#!/bin/bash -e
# This script only works on mac

# Update local hosts file
METADATA_STORE_IP=$(kubectl get svc metadata-store-app -n metadata-store -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
# delete any previously added entry for meta data store
sudo sed -i '' '/metadata-store-app/d' /etc/hosts
echo "$METADATA_STORE_IP metadata-store-app" | sudo tee -a /etc/hosts > /dev/null

# configure insight
insight config set-target https://metadata-store-app:8443 \
    --ca-cert <(kubectl get secret app-tls-cert -n metadata-store -ojsonpath="{.data.ca\.crt}" | base64 --decode) \
    --access-token $(kubectl get secret $(kubectl get sa -n metadata-store metadata-store-read-write-client -o json | jq -r '.secrets[0].name') -n metadata-store -o json | jq -r '.data.token' | base64 -d)
