# Scan a Model from AWS S3

> **What you'll learn:** scan models stored in AWS S3 directly (no local download), the cloud-native pattern for production MLOps pipelines and model-registry security gates.
>
> These steps run in the **Shell** tab of the cloud client, which already has AWS credentials from the sandbox account. Use the **Cloud Credentials** tab to sign in to the AWS console.

In enterprise environments, models live in cloud object storage, not on local filesystems.

## Background: Why S3 for Model Storage?

S3 is the industry standard for storing ML models in production: unlimited scalable storage, 11 nines of durability, versioning, fine-grained IAM access control, native integration with SageMaker/Databricks/MLflow, and pay-per-use cost efficiency.

Cloud-stored models still need scanning: supply-chain attacks, third-party/vendor models, new versions introducing vulnerabilities, shared buckets, and automated pipelines all warrant a security gate. Downloading each model to scan it locally is slow, error-prone, and wastes bandwidth. `scan_s3_model()` scans directly from S3.

---

## The Scenario

A scikit-learn RandomForest model has been uploaded to an S3 bucket in your sandbox AWS account. Your task: scan it for vulnerabilities before using it.

---

## Step 1: Load API Credentials

```bash
source ~/credentials.env
```

Your AWS credentials are already configured in this environment (as `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` environment variables), so `boto3` authenticates automatically.

---

## Step 2: View S3 Details

S3 uses a two-level hierarchy: a globally-unique **bucket** and an object **key** (path within the bucket).

Check your bucket details:
```bash
# Bucket name is saved here
cat /tmp/s3_bucket_name.txt

# List contents
aws s3 ls s3://$(cat /tmp/s3_bucket_name.txt)/
```

You should see `s3_model.pkl` listed, confirming the bucket exists, the model is uploaded, and your credentials have read access.

---

## Step 3: Create S3 Scan Script

`scan_s3_model()` uses your AWS credentials to stream the model directly from S3 to HiddenLayer's API. The model never touches the local filesystem.
```bash
cat > ~/scan_s3.py << 'EOF'
import os
from hiddenlayer import HiddenLayer

# Get bucket name
with open('/tmp/s3_bucket_name.txt', 'r') as f:
    bucket_name = f.read().strip()

# Initialize client
client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

# Scan S3 model
print(f"Scanning model from S3 bucket: {bucket_name}")
result = client.model_scanner.scan_s3_model(
    model_name="s3_stored_model",
    bucket=bucket_name,
    key="s3_model.pkl"
)

print("\n=== Scan Results Summary ===")
print(f"Status: {result.status}")
print(f"Overall Severity: {result.severity}")
print(f"Total Detections: {result.detection_count}")
print(f"Files Scanned: {result.file_count}")
print(f"Files with Detections: {result.files_with_detections_count}")

if result.file_results:
    print(f"\n=== File Details ===")
    for file_result in result.file_results:
        filename = file_result.file_location.split('/')[-1] if '/' in file_result.file_location else file_result.file_location
        print(f"\n  File: {filename}")
        print(f"  Type: {file_result.details.file_type}")
        print(f"  SHA256: {file_result.details.sha256}")
        print(f"  Status: {file_result.status}")

        if file_result.detections and len(file_result.detections) > 0:
            print(f"  Detections: {len(file_result.detections)}")
            for i, detection in enumerate(file_result.detections, 1):
                print(f"\n    [{i}] {detection.category} (Severity: {detection.severity})")
                print(f"        {detection.description}")
                print(f"        Rule: {detection.rule_id}")
        else:
            print(f"  No issues detected")
EOF
```

`scan_s3_model()` takes `model_name` (tracking identifier), `bucket` (the container), and `key` (the object path within the bucket).

---

## Step 4: Run the Scan

```bash
python3 ~/scan_s3.py
```

boto3 retrieves credentials, calls `s3:GetObject`, and streams the model to HiddenLayer. Expect 5-10 seconds.

---

## Understanding S3 Scan Results

For this clean model:

```
Scanning model from S3 bucket: hiddenlayer-models-1770566022

=== Scan Results Summary ===
Status: done
Overall Severity: safe
Total Detections: 0
Files Scanned: 1
Files with Detections: 0
```

## Real-World Integration

Use `scan_s3_model()` as a CI/CD security gate (block deploys when severity is high/critical), for scheduled bucket audits, or before registering a model in MLflow/SageMaker. Grant least-privilege IAM (`s3:GetObject`, `s3:ListBucket`).

**Troubleshooting:** "Access Denied" (missing `s3:GetObject`), "NoSuchBucket" (wrong name), "NoSuchKey" (wrong key).

---

<instruqt-task id="complete"></instruqt-task>

**Next:** in Challenge 6 you'll do the same from Azure Blob Storage.
