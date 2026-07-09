# Scan a Model from Azure Blob Storage

> **What you'll learn:** scan models in Azure Blob Storage, demonstrating multi-cloud ML security with the same unified SDK you used for S3.
>
> These steps run in the **Shell** tab of the cloud client, which is already signed in to Azure via a service principal.

In Challenge 5 you scanned from AWS S3. Now you'll do the same from Azure Blob Storage; the same security workflow applies across cloud providers.

## The Scenario

An Azure Storage Account has been provisioned with a **container** named `models` holding a blob `azure_model.pkl`.

---

## Step 1: Load Environment Variables

```bash
source ~/credentials.env
```

This time `credentials.env` also includes Azure-specific variables (`STORAGE_ACCOUNT`, `RESOURCE_GROUP`, `CONTAINER_NAME`) alongside your HiddenLayer credentials.

This environment is already authenticated to Azure using a service principal (the `az login` was performed during provisioning), and the `azure-storage-blob` and `azure-identity` libraries are pre-installed.

---

## Step 2: View Storage Details

Azure Blob Storage uses a three-level hierarchy: **Storage Account** -> **Container** -> **Blob**.

Check your storage configuration:
```bash
# View the storage account name
echo $STORAGE_ACCOUNT

# List blobs in the container
az storage blob list \
    --account-name "${STORAGE_ACCOUNT}" \
    --container-name "${CONTAINER_NAME}" \
    --output table \
    --auth-mode login
```

You should see `azure_model.pkl` listed, confirming the storage account and container exist and your credentials have read access.

---

## Step 3: Create Azure Scan Script

`scan_azure_blob_model()` uses your Azure credentials to connect to the storage account and stream the blob to HiddenLayer's API.
```bash
cat > ~/scan_azure.py << 'EOF'
import os
from hiddenlayer import HiddenLayer

storage_account = os.getenv('STORAGE_ACCOUNT')
container_name = os.getenv('CONTAINER_NAME')

client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

print(f"Scanning model from Azure Storage Account: {storage_account}")
result = client.model_scanner.scan_azure_blob_model(
    model_name="azure_stored_model",
    account_url=f"https://{storage_account}.blob.core.windows.net",
    container=container_name,
    blob="azure_model.pkl"
)

print(f"\n=== Scan Results Summary ===")
print(f"Status: {result.status}")
print(f"Overall Severity: {result.severity}")
print(f"Total Detections: {result.detection_count}")
print(f"Files Scanned: {result.file_count}")
print(f"Files with Detections: {result.files_with_detections_count}")
EOF
```

`scan_azure_blob_model()` takes `model_name`, `account_url` (the full storage account URL), `container`, and `blob`.

**Compared with S3:** the storage location is `account_url` + `container` (vs `bucket`), the object is `blob` (vs `key`), and auth uses the Azure service principal via `azure-identity` (vs boto3/IAM). The SDK abstracts these differences.

The SDK uses `DefaultAzureCredential`, which discovers the active service-principal session automatically.

---

## Step 4: Run the Scan

```bash
python3 ~/scan_azure.py
```

Expect 5-10 seconds, comparable to S3 scanning.

---

## Understanding Azure Scan Results

For this clean model:

```
Scanning model from Azure Storage Account: hlmodels770567425

=== Scan Results Summary ===
Status: done
Overall Severity: safe
Total Detections: 0
Files Scanned: 1
Files with Detections: 0
```

## Multi-Cloud Security: Key Insights

1. **Unified API**: the same SDK pattern works for AWS S3 and Azure Blob
2. **Cloud-agnostic security**: rules apply consistently regardless of provider
3. **Native integration**: each cloud's SDK (boto3, azure-storage-blob) is abstracted away
4. **Operational efficiency**: one tool for multi-cloud environments

**Troubleshooting:** "AuthenticationFailed" (SP not authenticated / missing Storage Blob Data Reader role), "ResourceNotFound" (wrong account/container/blob name).

---

<instruqt-task id="complete"></instruqt-task>

**Next:** in Challenge 7 you'll scan a model from any HTTP/HTTPS URL.
