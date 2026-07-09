# Scan a HuggingFace Model

> **What you'll learn:** scan community models from the HuggingFace Hub to detect supply-chain threats, backdoors, and malicious code before you use them.

Welcome to one of the most critical ML security workflows: scanning community-sourced models before use.

## Background: The HuggingFace Ecosystem

HuggingFace is the world's largest repository of pre-trained ML models (500,000+), covering NLP, computer vision, audio, and multimodal models. Teams use it for transfer learning, state-of-the-art performance, and community innovation.

**The security challenge:** this democratization introduces **supply chain risks**. Models from unknown sources may contain:
- **Backdoors**: hidden triggers that cause misclassification
- **Data Exfiltration**: code that steals sensitive data when the model loads
- **Model Poisoning**: weights manipulated to produce harmful outputs
- **Malicious Code**: arbitrary code execution vulnerabilities

---

## The Vulnerable Model

For this challenge you'll scan **`drhyrum/bert-tiny-torch-vuln`**, a deliberately vulnerable model created for security training. It demonstrates embedded malicious code in PyTorch serialization, network request capabilities (data exfiltration), and unsafe deserialization patterns.

> **Note:** this model is safe to *scan* in a sandboxed environment, but you should never *load or execute* untrusted models without scanning first.

---

## Step 1: Load API Credentials

```bash
source ~/credentials.env
```

---

## Step 2: Create HuggingFace Scan Script

`scan_huggingface_model()` connects to the Hub using the `repo_id`, downloads model files to a temporary location, scans them, returns a consolidated report, and cleans up automatically. Under the hood it uses the `huggingface_hub` library (pre-installed), so you don't interact with it directly.
```bash
cat > ~/scan_huggingface.py << 'EOF'
import os
from hiddenlayer import HiddenLayer

# Initialize client
client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

# Scan HuggingFace model
print("Scanning HuggingFace model: drhyrum/bert-tiny-torch-vuln")
print("This model is known to contain vulnerabilities...")

result = client.model_scanner.scan_huggingface_model(
    repo_id="drhyrum/bert-tiny-torch-vuln"
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

`repo_id` uses the `username/model-name` format (same as HuggingFace URLs). The SDK scans model files (weights, configs) while ignoring non-executable metadata.

---

## Step 3: Run the Scan

```bash
python3 ~/scan_huggingface.py
```

---

## Understanding the Results

Unlike the clean models in Challenges 2-3, this model is **intentionally vulnerable**. You should see something like:

```
=== Scan Results Summary ===
Status: done
Overall Severity: high
Total Detections: 1
Files Scanned: 6
Files with Detections: 1

=== File Details ===

File: pytorch_model.bin
  Type: pytorch
  Status: done
  Detections: 1

    [1] Network Requests (Severity: high)
        This detection rule was triggered by the presence of a function or
        library that can be used to exfiltrate data. Offending module / function: webbrowser.
        Rule: PICKLE_0057_202408
        Info: https://hiddenlayer.com/research/pickle-strike/
```

**Key findings:** `pytorch_model.bin` is the compromised weight file; the detection is a network-request (exfiltration) capability via an embedded `webbrowser` module; severity is high.

## Best Practices for HuggingFace Models

1. Always scan before use
2. Prioritize verified organizations and trusted authors
3. Review model cards for red flags
4. Prefer `.safetensors` over pickle-based serialization
5. Scan the entire dependency tree
6. Re-scan periodically as new vulnerabilities emerge

---

<instruqt-task id="complete"></instruqt-task>

**Next:** in Challenge 5 you'll scan models stored in AWS S3.
