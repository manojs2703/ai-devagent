# install.ps1 — Installs the ai-devagent plugin to a hidden user-level folder
# Usage:
#   .\install.ps1                          # install from current repo
#   .\install.ps1 -RepoUrl <git-url>       # clone from private GitHub repo

param(
    [string]$RepoUrl = "",
    [string]$InstallRoot = "$env:USERPROFILE\.ai-devagent"
)

$PluginContent = Join-Path $InstallRoot "ai-devagent"

# --- Install or update plugin source ---
if ($RepoUrl) {
    if (Test-Path $InstallRoot) {
        Write-Host "Updating plugin from repo..."
        git -C $InstallRoot pull
    } else {
        Write-Host "Cloning plugin from $RepoUrl..."
        git clone $RepoUrl $InstallRoot
    }
} else {
    $Source = Join-Path $PSScriptRoot "ai-devagent"
    if (-not (Test-Path $Source)) {
        Write-Error "Plugin source not found: $Source"
        exit 1
    }
    Write-Host "Copying plugin to $InstallRoot..."
    if (Test-Path $InstallRoot) {
        Remove-Item $InstallRoot -Recurse -Force
    }
    Copy-Item $Source -Destination $PluginContent -Recurse
}

# Hide the folder from Explorer
attrib +h $InstallRoot

Write-Host "Installed: $PluginContent"
Write-Host "Done. Reference path for copilot-instructions.md: $PluginContent"
