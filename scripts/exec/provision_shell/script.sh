#!/bin/bash
# Provisioning for the workstation container (Challenges 1-4 and 7).
# Consolidates the V1 per-challenge setup scripts into one idempotent run.
set -euxo pipefail

# ---------------------------------------------------------------------------
# Virtual environment + SDK and all dependencies used across the challenges
# ---------------------------------------------------------------------------
python3 -m venv /root/hiddenlayer-env
source /root/hiddenlayer-env/bin/activate
pip install --quiet --upgrade pip
pip install --quiet hiddenlayer-sdk scikit-learn huggingface_hub requests

# ---------------------------------------------------------------------------
# Sample models
#   Challenge 2 scans the single file /root/models/example_model.pkl
#   Challenge 3 scans the folder /root/models/batch (exactly 3 models)
# ---------------------------------------------------------------------------
mkdir -p /root/models/batch

python3 << 'PYEOF'
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_classification

X, y = make_classification(n_samples=100, n_features=4, random_state=42)

# Challenge 2: single model
single = RandomForestClassifier(n_estimators=10, random_state=42)
single.fit(X, y)
with open('/root/models/example_model.pkl', 'wb') as f:
    pickle.dump(single, f)

# Challenge 3: folder of models
model1 = RandomForestClassifier(n_estimators=10, random_state=42)
model1.fit(X, y)
with open('/root/models/batch/model_1.pkl', 'wb') as f:
    pickle.dump(model1, f)

model2 = DecisionTreeClassifier(random_state=42)
model2.fit(X, y)
with open('/root/models/batch/model_2.pkl', 'wb') as f:
    pickle.dump(model2, f)

model3 = LogisticRegression(random_state=42)
model3.fit(X, y)
with open('/root/models/batch/model_3.pkl', 'wb') as f:
    pickle.dump(model3, f)
PYEOF

# ---------------------------------------------------------------------------
# Challenge 7: local HTTP server serving a model to scan from a URL
# ---------------------------------------------------------------------------
python3 << 'PYEOF'
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)
with open('/tmp/remote_model.pkl', 'wb') as f:
    pickle.dump(model, f)
PYEOF

# Start detached so it survives after this exec session ends (PID 1 is
# `sleep infinity`, which adopts the reparented process).
setsid nohup python3 -m http.server 8000 --directory /tmp > /var/log/http_server.log 2>&1 < /dev/null &

# ---------------------------------------------------------------------------
# Credentials file the challenges `source`, plus auto-activate the venv
# ---------------------------------------------------------------------------
cat > /root/credentials.env << EOF
export HIDDENLAYER_CLIENT_ID="${HIDDENLAYER_CLIENT_ID}"
export HIDDENLAYER_CLIENT_SECRET="${HIDDENLAYER_CLIENT_SECRET}"
EOF

if ! grep -q 'hiddenlayer-env/bin/activate' /root/.bashrc 2>/dev/null; then
  echo 'source /root/hiddenlayer-env/bin/activate' >> /root/.bashrc
fi
