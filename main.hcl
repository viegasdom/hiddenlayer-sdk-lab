# =============================================================================
# HiddenLayer SDK Lab
# Ported from the V1 track "hiddenlayer-sdk-track" (jparton-challenge).
# =============================================================================

resource "lab" "hiddenlayer_sdk" {
  title       = "HiddenLayer SDK Track"
  description = "Detect security threats in ML models using HiddenLayer's SDK. Scan local files, folders, HuggingFace models, AWS S3, Azure Blob, and remote URLs to protect production ML systems from supply chain attacks."

  settings {
    idle {
      enabled      = true
      show_warning = true
      timeout      = "5m"
    }
  }

  layout = resource.layout.workstation

  content {
    chapter "setup" {
      title = "Setup & Authentication"

      page "setup_authentication" {
        title     = "Challenge 1: Setup & Authentication"
        reference = resource.page.setup_authentication
      }
    }

    chapter "local_batch" {
      title = "Local & Batch Scanning"

      page "scan_local_model" {
        title     = "Challenge 2: Scan a Local Model File"
        reference = resource.page.scan_local_model
      }

      page "scan_folder" {
        title     = "Challenge 3: Scan a Folder of Models"
        reference = resource.page.scan_folder
      }
    }

    chapter "community" {
      title = "Community Models"

      page "scan_huggingface" {
        title     = "Challenge 4: Scan a HuggingFace Model"
        reference = resource.page.scan_huggingface
      }
    }

    chapter "cloud_storage" {
      title  = "Cloud Storage"
      layout = resource.layout.cloud

      page "scan_s3_model" {
        title     = "Challenge 5: Scan a Model from S3"
        reference = resource.page.scan_s3_model
      }

      page "scan_azure_blob" {
        title     = "Challenge 6: Scan from Azure Blob Storage"
        reference = resource.page.scan_azure_blob
      }
    }

    chapter "remote" {
      title = "Remote URLs"

      page "community_scanner" {
        title     = "Challenge 7: Community Scanner"
        reference = resource.page.community_scanner
      }
    }
  }
}
