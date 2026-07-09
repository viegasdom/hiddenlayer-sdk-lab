# Scan a Local Model File

> **What you'll learn:** scan a single model file on the local filesystem, understand pickle serialization vulnerabilities, and interpret security scan results.

Now that you're authenticated, let's scan your first ML model for security vulnerabilities!

## Background: Why Scan Local Models?

In many ML workflows, models are developed and trained locally before deployment. These models can contain hidden security risks:

- **Serialization vulnerabilities**: Pickle files (`.pkl`) can execute arbitrary code when loaded
- **Embedded malicious code**: Attackers can inject backdoors during model creation or fine-tuning
- **Supply chain poisoning**: Pre-trained models from untrusted sources may be compromised

**The scenario:** a sample scikit-learn RandomForest model has been pre-staged at `/root/models/example_model.pkl`. This represents a typical ML model file you might receive from a data science team.

---

## Step 1: Load API Credentials

Just like in Challenge 1, load your HiddenLayer credentials into the current shell session:
```bash
source ~/credentials.env
```

Confirm they're loaded:
```bash
echo "Client ID starts with: ${HIDDENLAYER_CLIENT_ID:0:8}..."
```

---

## Step 2: Create Scan Script

The `scan_file()` method is the simplest way to scan a local model file. It uploads the file to HiddenLayer's secure scanning infrastructure, analyzes the model's serialized format for security threats, and returns a detailed report.

Create your scanning script:
```bash
cat > ~/scan_local.py << 'EOF'
import os
from hiddenlayer import HiddenLayer

# Initialize client with pre-configured credentials
client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

# Scan the local model
print("Scanning local model...")
result = client.model_scanner.scan_file(
    model_path="/root/models/example_model.pkl",
    model_name="example_sklearn_model"
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
                if detection.technical_blog_href:
                    print(f"        Info: {detection.technical_blog_href}")
        else:
            print(f"  No issues detected")
EOF
```

**Key parameters:**
- `model_path`: the filesystem path to the model file
- `model_name`: a friendly identifier for this scan (used in the HiddenLayer platform for tracking)

---

## Step 3: Run the Scan

Execute your scan script:
```bash
python3 ~/scan_local.py
```

Scanning uploads the file, analyzes its structure and serialization format, applies detection rules, and returns results with severity ratings. Expect 5-10 seconds for a small model.

---

## Understanding the Results

- **Status** — `done` (completed) or `failed`
- **Overall Severity** — `safe`, or `low`/`medium`/`high`/`critical` when threats are found
- **Detection Count** — total number of security findings
- **Files Scanned / Files with Detections** — counts across the scan

For each file you also see the file type, SHA256 hash, per-file status, and any detections (category, severity, description, rule ID, info link).

## What to Expect

For this clean scikit-learn model you should see status `done`, severity `safe`, and `0` detections. In real scenarios, malicious models would trigger detections for suspicious imports (`os`, `subprocess`, `socket`), network connection attempts, filesystem access, or known vulnerability signatures.

---

<instruqt-task id="complete"></instruqt-task>

**Next:** in Challenge 3 you'll scan an entire folder of models in one batch operation.
