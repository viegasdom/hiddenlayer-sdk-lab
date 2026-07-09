#!/bin/bash
# Provisioning for the cloud client container (Challenges 5 and 6).
# Creates and populates the S3 bucket and the Azure storage account/blob,
# and writes the credentials file the challenges source.
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# Base tooling: python venv, AWS CLI, Azure CLI
# ---------------------------------------------------------------------------
apt-get update -qq
apt-get install -y -qq python3-venv python3-pip curl ca-certificates jq

# Azure CLI (Microsoft apt repo installer)
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

python3 -m venv /root/hiddenlayer-env
source /root/hiddenlayer-env/bin/activate
pip install --quiet --upgrade pip
pip install --quiet hiddenlayer-sdk boto3 azure-storage-blob azure-identity scikit-learn awscli

# ===========================================================================
# AWS S3 (Challenge 5): create bucket, generate model, upload
# ===========================================================================
BUCKET_NAME="hiddenlayer-models-$(date +%s)"
REGION="us-east-1"

aws s3 mb "s3://${BUCKET_NAME}" --region "${REGION}"

mkdir -p /root/models
python3 << 'PYEOF'
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)
with open('/root/models/s3_model.pkl', 'wb') as f:
    pickle.dump(model, f)
PYEOF

aws s3 cp /root/models/s3_model.pkl "s3://${BUCKET_NAME}/s3_model.pkl"
echo "${BUCKET_NAME}" > /tmp/s3_bucket_name.txt

# ===========================================================================
# Azure Blob (Challenge 6): login, create storage account/container, upload
# ===========================================================================
for i in {1..12}; do
  az login --service-principal \
    --username "${AZURE_CLIENT_ID}" \
    --password "${AZURE_CLIENT_SECRET}" \
    --tenant "${AZURE_TENANT_ID}" && break || sleep 10
done

az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

az provider register --namespace Microsoft.Storage --wait

STORAGE_ACCOUNT="hlmodels$(date +%s | tail -c 10 | tr -d '\n')"
RESOURCE_GROUP="hiddenlayer-rg"
CONTAINER_NAME="models"

az group create --name "${RESOURCE_GROUP}" --location "eastus" --output none

az storage account create \
  --name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --location "eastus" \
  --sku "Standard_LRS" \
  --output none

STORAGE_KEY=$(az storage account keys list \
  --account-name "${STORAGE_ACCOUNT}" \
  --resource-group "${RESOURCE_GROUP}" \
  --query '[0].value' -o tsv)

az storage container create \
  --name "${CONTAINER_NAME}" \
  --account-name "${STORAGE_ACCOUNT}" \
  --account-key "${STORAGE_KEY}" \
  --output none

python3 << 'PYEOF'
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)
with open('/root/models/azure_model.pkl', 'wb') as f:
    pickle.dump(model, f)
PYEOF

az storage blob upload \
  --account-name "${STORAGE_ACCOUNT}" \
  --container-name "${CONTAINER_NAME}" \
  --name "azure_model.pkl" \
  --file "/root/models/azure_model.pkl" \
  --account-key "${STORAGE_KEY}" \
  --output none

# ---------------------------------------------------------------------------
# Credentials file the challenges source, plus auto-activate the venv
# ---------------------------------------------------------------------------
cat > /root/credentials.env << EOF
export HIDDENLAYER_CLIENT_ID="${HIDDENLAYER_CLIENT_ID}"
export HIDDENLAYER_CLIENT_SECRET="${HIDDENLAYER_CLIENT_SECRET}"
export STORAGE_ACCOUNT="${STORAGE_ACCOUNT}"
export RESOURCE_GROUP="${RESOURCE_GROUP}"
export CONTAINER_NAME="${CONTAINER_NAME}"
EOF

if ! grep -q 'hiddenlayer-env/bin/activate' /root/.bashrc 2>/dev/null; then
  echo 'source /root/hiddenlayer-env/bin/activate' >> /root/.bashrc
fi
