# Setup & Authentication

> **What you'll learn:** install the HiddenLayer Python SDK, configure API credentials, and initialize an authenticated client. Every ML security workflow starts here.

Welcome to the HiddenLayer SDK training! In this first challenge, you'll learn how to set up a Python environment for ML security scanning and authenticate with HiddenLayer's Model Scanner service.

**What You'll Learn:**
- How to create isolated Python environments for security tools
- How to install and verify the HiddenLayer SDK
- How to load API credentials and authenticate with HiddenLayer's API

## Background: Why HiddenLayer?

HiddenLayer's Model Scanner detects security threats in ML models, including:
- **Malicious code injection** (backdoors, data exfiltration)
- **Model poisoning** (manipulated weights)
- **Supply chain risks** (unsafe dependencies)

The Python SDK provides programmatic access to scan models from various sources.

---

## Step 1: Create Virtual Environment

A Python virtual environment is an isolated workspace that keeps project dependencies separate from your system Python. It has been pre-created and auto-activated for you in this environment at `~/hiddenlayer-env`, so you should already see `(hiddenlayer-env)` at the start of your prompt.

If you ever need to activate it manually:
```bash
source ~/hiddenlayer-env/bin/activate
```

---

## Step 2: Verify the HiddenLayer SDK

The HiddenLayer SDK (`hiddenlayer-sdk`) is a Python library that provides easy-to-use interfaces for scanning ML models. It handles authentication, file uploads, and result parsing automatically. It is pre-installed in this environment.

> **Note:** there is a separate package called `hiddenlayer` (without `-sdk`) used for neural network visualization. This training uses `hiddenlayer-sdk` for security scanning.

Confirm the installation:
```bash
pip show hiddenlayer-sdk
```

**What to look for:** the output should show package details including version, location, and dependencies.

---

## Step 3: Load API Credentials

HiddenLayer uses OAuth2-style client credentials (Client ID and Secret) to authenticate API requests. These credentials have been pre-staged in a file called `~/credentials.env` for this training environment.

Load the credentials into your shell session:
```bash
source ~/credentials.env
```

This sets two environment variables your scripts will use:
- `HIDDENLAYER_CLIENT_ID` — your unique identifier
- `HIDDENLAYER_CLIENT_SECRET` — your authentication secret (keep this secure!)

Verify the credentials loaded correctly:
```bash
echo "Client ID starts with: ${HIDDENLAYER_CLIENT_ID:0:8}..."
```

**Why a separate credentials file?** In production, credentials are stored outside of scripts and sourced at runtime. This keeps secrets out of version control and makes rotation easier, mirroring how teams manage secrets in CI/CD pipelines.

---

## Step 4: Create Authentication Test Script

Now create a script to verify end-to-end authentication with HiddenLayer's API:
```bash
cat > ~/test_connection.py << 'EOF'
import os
from hiddenlayer import HiddenLayer

# Credentials are pre-configured in your environment
client_id = os.getenv('HIDDENLAYER_CLIENT_ID')
client_secret = os.getenv('HIDDENLAYER_CLIENT_SECRET')

# Create client
client = HiddenLayer(
    client_id=client_id,
    client_secret=client_secret,
    environment="prod-us"
)

print("HiddenLayer client initialized successfully!")
print(f"Using Client ID: {client_id[:8]}...")
EOF
```

---

## Step 5: Run Authentication Test

Execute the test script:
```bash
python3 ~/test_connection.py
```

**Expected output:**
```
HiddenLayer client initialized successfully!
Using Client ID: 6d8e9cdb...
```

**Troubleshooting:**
- `ModuleNotFoundError`: make sure the virtual environment is active (`source ~/hiddenlayer-env/bin/activate`)
- `NoneType` errors: the credentials weren't loaded; run `source ~/credentials.env` and try again

---

<instruqt-task id="complete"></instruqt-task>

## What's Next?

In the following challenges, you'll use this authenticated client to scan models from local files, folders, HuggingFace, cloud storage (AWS S3, Azure Blob), and remote URLs.
