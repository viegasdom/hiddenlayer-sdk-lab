# =============================================================================
# Pages - one per V1 challenge. Each wires a completion task as an activity.
# =============================================================================

resource "page" "setup_authentication" {
  title = "Challenge 1: Setup & Authentication"
  file  = "instructions/01-setup-authentication.md"

  activities = {
    complete = resource.task.setup_authentication
  }
}

resource "page" "scan_local_model" {
  title = "Challenge 2: Scan a Local Model File"
  file  = "instructions/02-scan-local-model.md"

  activities = {
    complete = resource.task.scan_local_model
  }
}

resource "page" "scan_folder" {
  title = "Challenge 3: Scan a Folder of Models"
  file  = "instructions/03-scan-folder.md"

  activities = {
    complete = resource.task.scan_folder
  }
}

resource "page" "scan_huggingface" {
  title = "Challenge 4: Scan a HuggingFace Model"
  file  = "instructions/04-scan-huggingface.md"

  activities = {
    complete = resource.task.scan_huggingface
  }
}

resource "page" "scan_s3_model" {
  title = "Challenge 5: Scan a Model from S3"
  file  = "instructions/05-scan-s3-model.md"

  activities = {
    complete = resource.task.scan_s3_model
  }
}

resource "page" "scan_azure_blob" {
  title = "Challenge 6: Scan from Azure Blob Storage"
  file  = "instructions/06-scan-azure-blob.md"

  activities = {
    complete = resource.task.scan_azure_blob
  }
}

resource "page" "community_scanner" {
  title = "Challenge 7: Community Scanner"
  file  = "instructions/07-community-scanner.md"

  activities = {
    complete = resource.task.community_scanner
  }
}
