# =============================================================================
# HiddenLayer SDK Lab - Sandbox (infrastructure)
#
# Ported from the V1 track "hiddenlayer-sdk-track" (config.yml):
#   - virtualmachine "shell-hl"          -> container "shell_hl"   (terminal + editor)
#   - container      "cloud-client"      -> container "cloud_client" (cloud steps)
#   - aws_accounts   "hiddenlayer-aws"   -> aws_account "hiddenlayer_aws"
#   - azure_subscriptions "hiddenlayer-azure" -> azure_subscription "hiddenlayer_azure"
#   - secrets demo_client_id / demo_client_secret -> secret resources
#
# V1 ran a per-challenge setup script. A V2 lab provisions its sandbox once,
# so the per-challenge setup is consolidated into two idempotent exec
# resources (one per container).
# =============================================================================

resource "network" "main" {
  subnet = "10.0.5.0/24"
}

# -----------------------------------------------------------------------------
# Team secrets (HiddenLayer API credentials). These must exist in the team
# that connects this repo, under exactly these names.
# -----------------------------------------------------------------------------
resource "secret" "hl_client_id" {
  reference = "demo_client_id"
}

resource "secret" "hl_client_secret" {
  reference = "demo_client_secret"
}

# -----------------------------------------------------------------------------
# AWS sandbox account (Challenge 5 - scan a model from S3).
# Mirrors the V1 iam_policy: create bucket, list, put, get.
# -----------------------------------------------------------------------------
resource "aws_account" "hiddenlayer_aws" {
  regions  = ["us-east-1"]
  services = ["s3"]

  user "student" {
    managed_policies = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  }
}

# -----------------------------------------------------------------------------
# Azure sandbox subscription (Challenge 6 - scan a model from Azure Blob).
# A service principal drives provisioning (az login) and the SDK's
# DefaultAzureCredential; a user is exposed for portal access.
# -----------------------------------------------------------------------------
resource "azure_subscription" "hiddenlayer_azure" {
  regions  = ["eastus"]
  services = ["Microsoft.Storage", "Microsoft.Resources"]

  user "student" {
    roles = ["Contributor", "Storage Blob Data Contributor"]
  }

  service_principal "automation" {
    roles = ["Contributor", "Storage Blob Data Contributor"]
  }
}

# -----------------------------------------------------------------------------
# Workstation container (Challenges 1-4 and 7). Python base image so the
# SDK, its deps and the sample models install/run without extra tooling.
# -----------------------------------------------------------------------------
resource "container" "shell_hl" {
  image {
    name = "python:3.12"
  }

  # Keep the container alive so the terminal/editor can attach.
  command = ["sleep", "infinity"]

  resources {
    memory = 4096
  }

  network {
    id = resource.network.main.meta.id
  }

  environment = {
    HIDDENLAYER_CLIENT_ID     = resource.secret.hl_client_id.value
    HIDDENLAYER_CLIENT_SECRET = resource.secret.hl_client_secret.value
  }
}

# -----------------------------------------------------------------------------
# Cloud client container (Challenges 5 and 6). Ubuntu base so the Azure CLI
# installs via Microsoft's apt repo; AWS + Azure credentials are injected from
# the sandbox cloud accounts so boto3 / the Azure SDK authenticate with no
# manual setup by the learner.
# -----------------------------------------------------------------------------
resource "container" "cloud_client" {
  image {
    name = "ubuntu:24.04"
  }

  command = ["sleep", "infinity"]

  resources {
    memory = 2048
  }

  network {
    id = resource.network.main.meta.id
  }

  environment = {
    HIDDENLAYER_CLIENT_ID     = resource.secret.hl_client_id.value
    HIDDENLAYER_CLIENT_SECRET = resource.secret.hl_client_secret.value

    # AWS (boto3 picks these up automatically)
    AWS_ACCESS_KEY_ID     = resource.aws_account.hiddenlayer_aws.user.0.access_key_id
    AWS_SECRET_ACCESS_KEY = resource.aws_account.hiddenlayer_aws.user.0.secret_access_key
    AWS_DEFAULT_REGION    = "us-east-1"

    # Azure (EnvironmentCredential leg of DefaultAzureCredential)
    AZURE_CLIENT_ID       = resource.azure_subscription.hiddenlayer_azure.service_principal.0.app_id
    AZURE_CLIENT_SECRET   = resource.azure_subscription.hiddenlayer_azure.service_principal.0.password
    AZURE_TENANT_ID       = resource.azure_subscription.hiddenlayer_azure.tenant_id
    AZURE_SUBSCRIPTION_ID = resource.azure_subscription.hiddenlayer_azure.subscription_id
  }
}

# -----------------------------------------------------------------------------
# Provisioning (replaces the V1 per-challenge setup scripts).
# -----------------------------------------------------------------------------
resource "exec" "provision_shell" {
  target  = resource.container.shell_hl
  script  = "scripts/exec/provision_shell/script.sh"
  timeout = "600s"

  environment = {
    HIDDENLAYER_CLIENT_ID     = resource.secret.hl_client_id.value
    HIDDENLAYER_CLIENT_SECRET = resource.secret.hl_client_secret.value
  }
}

resource "exec" "provision_cloud" {
  target  = resource.container.cloud_client
  script  = "scripts/exec/provision_cloud/script.sh"
  timeout = "900s"

  environment = {
    HIDDENLAYER_CLIENT_ID     = resource.secret.hl_client_id.value
    HIDDENLAYER_CLIENT_SECRET = resource.secret.hl_client_secret.value

    AWS_ACCESS_KEY_ID     = resource.aws_account.hiddenlayer_aws.user.0.access_key_id
    AWS_SECRET_ACCESS_KEY = resource.aws_account.hiddenlayer_aws.user.0.secret_access_key
    AWS_DEFAULT_REGION    = "us-east-1"

    AZURE_CLIENT_ID       = resource.azure_subscription.hiddenlayer_azure.service_principal.0.app_id
    AZURE_CLIENT_SECRET   = resource.azure_subscription.hiddenlayer_azure.service_principal.0.password
    AZURE_TENANT_ID       = resource.azure_subscription.hiddenlayer_azure.tenant_id
    AZURE_SUBSCRIPTION_ID = resource.azure_subscription.hiddenlayer_azure.subscription_id
  }
}
