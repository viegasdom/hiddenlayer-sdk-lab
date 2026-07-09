# =============================================================================
# Tasks - lightweight completion checks (the V1 track had none). Each verifies
# the learner created the script for that challenge. Skipping is allowed.
# =============================================================================

resource "task" "setup_authentication" {
  description = "Create and run the authentication test script"

  config {
    target = resource.container.shell_hl
  }

  condition "script_created" {
    description = "~/test_connection.py exists and the SDK is installed"

    check {
      script          = "scripts/task/setup_authentication/check.sh"
      failure_message = "Create ~/test_connection.py (Step 4) and make sure the SDK installed in ~/hiddenlayer-env."
    }
  }
}

resource "task" "scan_local_model" {
  description = "Create the local model scan script"

  config {
    target = resource.container.shell_hl
  }

  condition "script_created" {
    description = "~/scan_local.py exists"

    check {
      script          = "scripts/task/scan_local_model/check.sh"
      failure_message = "Create ~/scan_local.py (Step 2)."
    }
  }
}

resource "task" "scan_folder" {
  description = "Create the folder scan script"

  config {
    target = resource.container.shell_hl
  }

  condition "script_created" {
    description = "~/scan_folder.py exists"

    check {
      script          = "scripts/task/scan_folder/check.sh"
      failure_message = "Create ~/scan_folder.py (Step 2)."
    }
  }
}

resource "task" "scan_huggingface" {
  description = "Create the HuggingFace scan script"

  config {
    target = resource.container.shell_hl
  }

  condition "script_created" {
    description = "~/scan_huggingface.py exists"

    check {
      script          = "scripts/task/scan_huggingface/check.sh"
      failure_message = "Create ~/scan_huggingface.py (Step 2)."
    }
  }
}

resource "task" "scan_s3_model" {
  description = "Create the S3 scan script"

  config {
    target = resource.container.cloud_client
  }

  condition "script_created" {
    description = "~/scan_s3.py exists"

    check {
      script          = "scripts/task/scan_s3_model/check.sh"
      failure_message = "Create ~/scan_s3.py (Step 3)."
    }
  }
}

resource "task" "scan_azure_blob" {
  description = "Create the Azure Blob scan script"

  config {
    target = resource.container.cloud_client
  }

  condition "script_created" {
    description = "~/scan_azure.py exists"

    check {
      script          = "scripts/task/scan_azure_blob/check.sh"
      failure_message = "Create ~/scan_azure.py (Step 3)."
    }
  }
}

resource "task" "community_scanner" {
  description = "Create the remote URL scan script"

  config {
    target = resource.container.shell_hl
  }

  condition "script_created" {
    description = "~/scan_remote.py exists"

    check {
      script          = "scripts/task/community_scanner/check.sh"
      failure_message = "Create ~/scan_remote.py (Step 3)."
    }
  }
}
