#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the AI DevAgent plugin globally and sets up a workspace for GitHub Copilot.

.DESCRIPTION
    Phase 1 (global, one-time): Clones the private ai-devagent plugin to
    $env:USERPROFILE\.ai-devagent\ and hides the folder.

    Phase 2 (per workspace): Creates CLAUDE.md, .github\copilot-instructions.md,
    .github\workspace-registry.md, and .github\prompts\*.prompt.md in the
    target workspace directory. CLAUDE.md and copilot-instructions.md are
    zoned documents (Plugin Role / Project Memory / Synced From) kept in
    sync per ai-devagent\memory\sync-protocol.md — re-running the installer
    only re-renders the Plugin Role zone, leaving learned project memory and
    synced entries untouched.

.PARAMETER WorkspaceRoot
    Path to the workspace where .github\ files will be created.
    Defaults to the current directory.

.PARAMETER SkipPluginInstall
    Skip Phase 1 (plugin already installed). Only re-generate workspace files.

.EXAMPLE
    # First-time full install in current directory
    .\install.ps1

.EXAMPLE
    # Install plugin + set up a specific workspace
    .\install.ps1 -WorkspaceRoot "C:\Dev\MyProject"

.EXAMPLE
    # Already have the plugin, just wire up a new workspace
    .\install.ps1 -WorkspaceRoot "C:\Dev\AnotherProject" -SkipPluginInstall
#>

param(
    [string]$WorkspaceRoot    = (Get-Location).Path,
    [switch]$SkipPluginInstall
)

$REPO_URL = "https://github.com/manojs2703/ai-devagent.git"

$PluginRoot    = "$env:USERPROFILE\.ai-devagent"
$PluginPath    = "$PluginRoot\ai-devagent"
$GithubDir     = Join-Path $WorkspaceRoot ".github"
$PromptsDir    = Join-Path $GithubDir "prompts"

function Write-Step($msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "   [!]  $msg" -ForegroundColor Yellow }

function Set-FileContent($path, $content) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
    Write-Ok $path
}

function Expand-Template($template) {
    $template -replace '__PLUGIN__', $PluginPath
}

function Get-ZoneContent($text, $zoneName) {
    if ([string]::IsNullOrEmpty($text)) { return $null }
    $pattern = "(?s)<!-- ZONE:${zoneName}:BEGIN -->\r?\n(.*?)\r?\n<!-- ZONE:${zoneName}:END -->"
    $m = [regex]::Match($text, $pattern)
    if ($m.Success) { return $m.Groups[1].Value } else { return $null }
}

function New-Zone($zoneName, $content) {
    "<!-- ZONE:${zoneName}:BEGIN -->`n$content`n<!-- ZONE:${zoneName}:END -->"
}

# Preserves the tool-owned zones (own + synced-from) across re-installs;
# only the Plugin Role zone is re-rendered from the plugin's current source.
function Set-ZonedDocument($path, $header, $pluginRoleContent, $ownZoneName, $ownZoneDefault, $syncZoneName, $syncZoneDefault) {
    $existing = $null
    if (Test-Path $path) { $existing = Get-Content $path -Raw }

    $ownContent = Get-ZoneContent $existing $ownZoneName
    if ([string]::IsNullOrEmpty($ownContent)) { $ownContent = $ownZoneDefault }

    $syncContent = Get-ZoneContent $existing $syncZoneName
    if ([string]::IsNullOrEmpty($syncContent)) { $syncContent = $syncZoneDefault }

    $doc = @(
        $header
        (New-Zone "PLUGIN_ROLE" $pluginRoleContent)
        (New-Zone $ownZoneName $ownContent)
        (New-Zone $syncZoneName $syncContent)
        ""
    ) -join "`n`n"

    Set-FileContent $path $doc
}

if (-not $SkipPluginInstall) {
    Write-Step "Phase 1: Installing AI DevAgent plugin globally"

    if (Test-Path $PluginRoot) {
        Write-Warn "Plugin already exists — pulling latest..."
        git -C $PluginRoot pull --quiet
        Write-Ok "Plugin updated at $PluginRoot"
    } else {
        Write-Host "   Cloning plugin (this may take a moment)..."
        git clone $REPO_URL $PluginRoot --quiet
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Clone failed. Check that you have access to $REPO_URL"
            exit 1
        }
        attrib +h $PluginRoot
        Write-Ok "Plugin installed at $PluginRoot"
    }
} else {
    Write-Warn "Skipping plugin install (-SkipPluginInstall)"
    if (-not (Test-Path $PluginPath)) {
        Write-Error "Plugin not found at $PluginPath. Run without -SkipPluginInstall first."
        exit 1
    }
}

Write-Step "Phase 2: Setting up workspace at $WorkspaceRoot"

New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null

$pluginRoleFull = Expand-Template (Get-Content (Join-Path $PluginPath "plugin-role.md") -Raw)
$pluginRoleFlat = Expand-Template (Get-Content (Join-Path $PluginPath "plugin-role.flat.md") -Raw)

$claudeHeader = Expand-Template @'
# CLAUDE.md — AI DevAgent Workspace Instructions

## How to use this file

This file is Claude Code's memory for this workspace. It stays in sync with
`.github\copilot-instructions.md` (GitHub Copilot's equivalent) via the
Memory Sync Protocol — see `__PLUGIN__\memory\sync-protocol.md` for the full
rules on zones, translation, and update flow.
'@

$projectMemoryDefault = @'
## Project Memory

<!-- Claude appends structured decision entries here. Format:
- [YYYY-MM-DD] Title
  decision: what was decided
  why: rationale
  where: affected files/paths
  status: active | superseded-by:<id>
-->
'@

$syncedFromCopilotDefault = Expand-Template @'
## Synced From Copilot

<!-- Compressed entries cross-written by Copilot after its own memory updates.
Promote into Project Memory above in Claude's native format, then prune here.
See __PLUGIN__\memory\sync-protocol.md for the translation rules. -->
'@

Set-ZonedDocument (Join-Path $WorkspaceRoot "CLAUDE.md") $claudeHeader $pluginRoleFull `
    "PROJECT_MEMORY" $projectMemoryDefault "SYNCED_FROM_COPILOT" $syncedFromCopilotDefault

$copilotHeader = Expand-Template @'
# GitHub Copilot — AI DevAgent Instructions

## How to use this file

This file is GitHub Copilot's memory for this workspace. It stays in sync
with `CLAUDE.md` (Claude Code's equivalent) via the Memory Sync Protocol —
see `__PLUGIN__\memory\sync-protocol.md` for the full rules on zones,
translation, and update flow.
'@

$projectRulesDefault = @'
## Project Rules

<!-- Copilot appends flat rule lines here. Format:
- [path/glob] Rule: <actionable instruction>. (est. YYYY-MM-DD)
-->
'@

$syncedFromClaudeDefault = Expand-Template @'
## Synced From Claude

<!-- Compressed entries cross-written by Claude after its own memory updates.
Promote into Project Rules above in Copilot's native format, then prune here.
See __PLUGIN__\memory\sync-protocol.md for the translation rules. -->
'@

Set-ZonedDocument (Join-Path $GithubDir "copilot-instructions.md") $copilotHeader $pluginRoleFlat `
    "PROJECT_RULES" $projectRulesDefault "SYNCED_FROM_CLAUDE" $syncedFromClaudeDefault

Set-FileContent (Join-Path $GithubDir "workspace-registry.md") @'
# Workspace Registry

**Purpose**: Lists all projects managed by the AI DevAgent in this workspace.
**Edit this file** to register your projects after installation.

---

## Workspace Root

`C:\Users\YOUR_USERNAME\path\to\workspace`   <- update this

---

## Project Index

| # | Project ID | Root Path | Type | AI Memory | Status |
|---|-----------|-----------|------|-----------|--------|
| 1 | MyProject | `MyProject/` | TBD | Not initialized | Active |

---

## Routing Rules

| User input contains | Target project |
|--------------------|----------------|
| "MyProject"        | MyProject       |

---

## Adding a Project

1. Add a row to the Project Index table
2. Add routing keywords to Routing Rules
3. Run `/discover {project}` to initialize AI memory
'@

$prompts = @{
    "analyse.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Analyse a Jira story before any implementation begins. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - create_file
  - mcp_atlassian-vw_read_jira_issue
  - mcp_atlassian-vw_search_jira_issues
'@
        body = @'
# /analyse — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\analyse.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "plan.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Create a detailed development plan from a story analysis. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - create_file
'@
        body = @'
# /plan — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\plan.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "implement.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Implement code changes based on the development plan. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - insert_edit_into_file
  - replace_string_in_file
  - create_file
  - run_in_terminal
  - get_errors
'@
        body = @'
# /implement — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\implement.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "test.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Write and verify tests for implemented code. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - insert_edit_into_file
  - replace_string_in_file
  - create_file
  - run_in_terminal
  - get_errors
'@
        body = @'
# /test — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\test.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "review.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Review code changes for quality and convention compliance. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - create_file
  - run_in_terminal
'@
        body = @'
# /review — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\review.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "commit.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Prepare a structured Git commit message for the current changes. Delegates to ai-devagent."
tools:
  - read_file
  - run_in_terminal
'@
        body = @'
# /commit — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\commit.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "doall.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Run the complete analyse → plan → implement → test → commit workflow end-to-end. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - insert_edit_into_file
  - replace_string_in_file
  - create_file
  - run_in_terminal
  - get_errors
  - mcp_atlassian-vw_read_jira_issue
  - mcp_atlassian-vw_search_jira_issues
'@
        body = @'
# /doall — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\doall.md` and execute **every step** defined there exactly as written.

Each sub-step (/analyse, /plan, /implement, /test, /commit) must in turn read and follow
its own devagent prompt file (`__PLUGIN__\prompts\{step}.md`).

Do not summarise or skip steps. Respect all stop conditions defined in the doall prompt.
'@
    }
    "propagate.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Decompose a story/task into work items and create a propagation plan. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - create_file
  - mcp_atlassian-vw_read_jira_issue
  - mcp_atlassian-vw_search_jira_issues
  - mcp_atlassian-vw_create_jira_issue
'@
        body = @'
# /propagate — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\propagate.md` and execute **every step** defined there exactly as written.

Also read `__PLUGIN__\agents\task-propagator.agent.md` as directed by that prompt.

Do not summarise or skip steps. Follow the full workflow from classification through memory update.
'@
    }
    "optimize.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Optimize a file or module for performance, readability, and convention compliance. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - insert_edit_into_file
  - replace_string_in_file
  - get_errors
'@
        body = @'
# /optimize — Delegate to AI DevAgent

Read the file `__PLUGIN__\agents\code-optimizer.agent.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow defined in that agent file.
'@
    }
    "translate.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Translate technical/business terms between languages or domains. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - insert_edit_into_file
'@
        body = @'
# /translate — Delegate to AI DevAgent

Read the file `__PLUGIN__\prompts\translate.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full workflow from context loading through memory update.
'@
    }
    "discover.prompt.md" = @{
        frontmatter = @'
mode: agent
description: "Initialize AI memory for a new project via project discovery. Delegates to ai-devagent."
tools:
  - read_file
  - file_search
  - grep_search
  - create_file
  - run_in_terminal
  - mcp_atlassian-vw_list_jira_projects
  - mcp_atlassian-vw_search_jira_issues
  - mcp_atlassian-vw-_search_confluence_pages
  - mcp_atlassian-vw-_read_confluence_page
'@
        body = @'
# /discover — Delegate to AI DevAgent

Read the file `__PLUGIN__\workflows\session-and-memory.md`, Project Discovery section, and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full discovery workflow.
'@
    }
}

foreach ($filename in $prompts.Keys) {
    $entry   = $prompts[$filename]
    $content = "---`n$($entry.frontmatter)---`n`n$(Expand-Template $entry.body)`n"
    Set-FileContent (Join-Path $PromptsDir $filename) $content
}

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " AI DevAgent — Installation Complete" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host " Plugin location  : $PluginPath" -ForegroundColor White
Write-Host " Workspace root   : $WorkspaceRoot\CLAUDE.md (Claude Code)" -ForegroundColor White
Write-Host " Workspace files  : $GithubDir (GitHub Copilot)" -ForegroundColor White
Write-Host ""
Write-Host " Next steps:" -ForegroundColor Yellow
Write-Host "   1. Edit .github\workspace-registry.md — add your projects"
Write-Host "   2. Open the workspace in IntelliJ"
Write-Host "   3. Use GitHub Copilot Chat — type /discover <project> to initialise a project"
Write-Host ""