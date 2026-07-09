# Scan a Folder of Models

> **What you'll learn:** batch-scan multiple model files in one operation to audit entire model directories, the pattern used in CI/CD pipelines and periodic security audits.

In production ML environments, you rarely work with just one model. Teams maintain model repositories with multiple versions, variants, or ensemble components that all need security validation.

## Background: Why Batch Scanning?

Common scenarios where folder scanning is essential:

1. **Model Registry Audits**: scan an entire repository to identify which models contain vulnerabilities
2. **CI/CD Pipeline Integration**: scan all models in a deployment package before release
3. **Periodic Security Reviews**: audit model directories to catch newly-discovered threats
4. **Ensemble Model Verification**: scan all components of ensemble systems
5. **Version Comparison**: check multiple model versions simultaneously

Instead of scanning files one-by-one with `scan_file()`, `scan_folder()` batches multiple models into a single operation.

---

## The Scenario

Three sample scikit-learn models have been pre-staged in `/root/models/batch/`:
- **Random Forest Classifier** — tree-based ensemble model
- **Decision Tree Classifier** — single decision tree model
- **Logistic Regression** — linear classification model

---

## Step 1: Load API Credentials

```bash
source ~/credentials.env
```

---

## Step 2: Create Folder Scan Script

The `scan_folder()` method recursively finds and scans all supported model files (`.pkl`, `.h5`, `.pt`, `.pb`, etc.) in a directory, uploads them in batch, scans them in parallel, and returns a consolidated report.
```bash
cat > ~/scan_folder.py << 'EOF'
import os
import time
from hiddenlayer import HiddenLayer

# Initialize client
client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

# Scan folder of models
print("Scanning folder of models...")
print("This may take 30-60 seconds for multiple files...")

start_time = time.time()

result = client.model_scanner.scan_folder(
    path="/root/models/batch",
    model_name="folder_scan"
)

elapsed = time.time() - start_time
print(f"\nScan completed in {elapsed:.1f} seconds")

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
                if detection.technical_blog_href:
                    print(f"        Info: {detection.technical_blog_href}")
        else:
            print(f"  No issues detected")
EOF
```

**Key difference from `scan_file()`:** `scan_file()` scans a single explicitly-specified file; `scan_folder()` automatically discovers and scans all model files in a directory.

---

## Step 3: Run the Folder Scan

```bash
python3 ~/scan_folder.py
```

Each model requires upload, deserialization/analysis, and security rule evaluation, so with 3 models expect 30-60 seconds total.

---

## Understanding Folder Scan Results

**Overall Severity** is the highest severity found across all files, so one critical model makes the whole folder critical. **Files with Detections** tells you what fraction of your inventory is compromised. You'll see one entry per file with its individual metadata and detections.

## What to Expect

For these clean models: status `done`, overall severity `safe`, total detections `0`, files scanned `3`, all marked "No issues detected".

In a real compromise, one file might show `high`/`critical` detections (e.g. network exfiltration or a suspicious `eval()` call), immediately identifying which model needs investigation.

---

<instruqt-task id="complete"></instruqt-task>

**Next:** in Challenge 4 you'll scan a model directly from HuggingFace without downloading it first.
