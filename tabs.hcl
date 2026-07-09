# =============================================================================
# Tabs
#   V1 shell-hl had a "Shell" (terminal) + "VSCode" (service :8443) tab
#     -> terminal.shell_hl + editor.shell_hl
#   V1 cloud-client had a "Shell" + "AWS Console"/"Azure Portal" (service :80)
#     -> terminal.cloud_client + cloud_credentials.cloud (console login details)
# =============================================================================

resource "terminal" "shell_hl" {
  target            = resource.container.shell_hl
  shell             = "/bin/bash"
  working_directory = "/root"
}

# Replaces the V1 code-server (VSCode) service tab.
resource "editor" "shell_hl" {
  workspace "home" {
    target    = resource.container.shell_hl
    directory = "/root"
  }
}

resource "terminal" "cloud_client" {
  target            = resource.container.cloud_client
  shell             = "/bin/bash"
  working_directory = "/root"
}

# Replaces the V1 "AWS Console" / "Azure Portal" service tabs: shows the
# console sign-in credentials for the sandbox AWS user and Azure user.
resource "cloud_credentials" "cloud" {
  aws_account {
    target = resource.aws_account.hiddenlayer_aws
    users  = ["student"]
  }

  azure_subscription {
    target = resource.azure_subscription.hiddenlayer_azure
    users  = ["student"]
  }
}
