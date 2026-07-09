# Community Scanner: Scan from a Remote URL

> **What you'll learn:** download and scan models from HTTP/HTTPS URLs, the final defense layer for community models shared via GitHub releases, research servers, CDNs, or private registries.

This is the final scanning method: remote URL scanning, which handles models distributed via HTTP/HTTPS.

## Background: Why URL-Based Distribution?

Models are frequently shared via direct URLs: research papers and competitions, GitHub release assets, CDN-hosted weights, private model servers, and blog/tutorial links.

## The Security Challenge

URL-distributed models are high-risk because there is no central verification: anyone can host a URL. Threats include typosquatting, compromised servers, man-in-the-middle tampering over HTTP, link rot/replacement, and social-engineering links. The workflow is: **Download -> Verify -> Scan -> Use (or quarantine)**.

## The Scenario

A local HTTP server (simulating a remote model host) is serving a model file on `http://localhost:8000/`. In production this could be a GitHub release, a research server, a CDN, or any HTTP-accessible model.

---

## Step 1: Load API Credentials

```bash
source ~/credentials.env
```

---

## Step 2: Verify Model Availability

Before downloading, confirm the URL is accessible. `curl -I` sends an HTTP HEAD request (headers only, no download):
```bash
curl -I http://localhost:8000/remote_model.pkl
```

**Expected output:**
```
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.12.x
Content-type: application/octet-stream
Content-Length: 12354
```

Check for `200 OK` and a binary `Content-Type`. Red flags: `404`/`403`, unexpected redirects, or `Content-Type: text/html` (an error page instead of the model).

---

## Step 3: Create Remote Scan Script

Unlike the HuggingFace/S3/Azure methods where the SDK handles the download, URL scanning uses a manual download (URLs are too diverse for one method) followed by the same `scan_file()` you used in Challenge 2.
```bash
cat > ~/scan_remote.py << 'EOF'
import os
import requests
from hiddenlayer import HiddenLayer

# Initialize client
client = HiddenLayer(
    client_id=os.getenv('HIDDENLAYER_CLIENT_ID'),
    client_secret=os.getenv('HIDDENLAYER_CLIENT_SECRET'),
    environment="prod-us"
)

# Remote model URL
url = "http://localhost:8000/remote_model.pkl"
local_path = "/tmp/downloaded_model.pkl"

print(f"Downloading model from: {url}")

# Download the remote model
response = requests.get(url)
with open(local_path, 'wb') as f:
    f.write(response.content)

print("Model downloaded successfully")

# Scan the downloaded file
print("Scanning downloaded model...")
result = client.model_scanner.scan_file(
    model_path=local_path,
    model_name="remote_url_model"
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

---

## Step 4: Run the Scan

```bash
python3 ~/scan_remote.py
```

The script sends an HTTP GET, writes the file to `/tmp/`, then scans it with `scan_file()`. Expect 5-10 seconds including download.

---

## Understanding the Results

For this clean model: status `done`, severity `safe`, `0` detections. The SHA256 hash lets you verify the download matches an expected fingerprint, detect if a URL later serves different content, and build allowlists of known-safe hashes.

## Security Best Practices for URL-Based Models

1. Always use HTTPS (prevents man-in-the-middle)
2. Verify SSL certificates (`verify=True`)
3. Check expected hashes when the source provides them
4. Scan before loading; never `pickle.load()` / `torch.load()` untrusted files first
5. Download to `/tmp/`, scan, then delete
6. Use timeouts, log downloads, validate against domain allowlists, and quarantine detected threats

**Never load before scanning:**
```python
# DANGEROUS - executes malicious code on load
model = pickle.load(open('downloaded_model.pkl', 'rb'))
```
```python
# SAFE - scan first, then decide
result = scan_file('downloaded_model.pkl')
if result.severity == 'safe':
    model = pickle.load(open('downloaded_model.pkl', 'rb'))
else:
    raise SecurityException("Model failed security scan")
```

---

<instruqt-task id="complete"></instruqt-task>

## Congratulations!

You've completed the HiddenLayer SDK training. Across 7 challenges you learned to scan models from local files, folders, HuggingFace, AWS S3, Azure Blob, and remote URLs; a complete ML security toolkit covering every common model distribution method.

**Remember:** in ML security, prevention is everything. Scan models *before* they enter your systems, never after an incident.
