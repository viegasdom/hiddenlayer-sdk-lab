# =============================================================================
# Layouts
#   workstation - instructions + shell terminal + VSCode editor (Challenges 1-4, 7)
#   cloud       - instructions + cloud terminal + cloud credentials (Challenges 5-6)
# =============================================================================

resource "layout" "workstation" {
  column {
    width = 45
    instructions {}
  }

  column {
    width = 55

    tab "shell" {
      title  = "Shell"
      target = resource.terminal.shell_hl
      active = true
    }

    tab "vscode" {
      title  = "VSCode"
      target = resource.editor.shell_hl
    }
  }
}

resource "layout" "cloud" {
  column {
    width = 45
    instructions {}
  }

  column {
    width = 55

    tab "shell" {
      title  = "Shell"
      target = resource.terminal.cloud_client
      active = true
    }

    tab "credentials" {
      title  = "Cloud Credentials"
      target = resource.cloud_credentials.cloud
    }
  }
}
