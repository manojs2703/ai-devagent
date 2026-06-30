#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the AI DevAgent plugin globally and sets up a workspace for GitHub Copilot.

.DESCRIPTION
    Phase 1 (global, one-time): Clones the private ai-devagent plugin to
    $env:USERPROFILE\.ai-devagent\ and hides the folder.

    Phase 2 (per workspace): Creates .github\copilot-instructions.md,
    .github\workspace-registry.md, and .github\prompts\*.prompt.md
    in the target workspace directory.

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

# ── Private plugin repo — fill in before sharing ─────────────────────────────
$REPO_URL = "https://github.com/manojs2703/ai-devagent.git"
# ─────────────────────────────────────────────────────────────────────────────

$PluginRoot    = "$env:USERPROFILE\.ai-devagent"
$PluginPath    = "$PluginRoot\ai-devagent"
$GithubDir     = Join-Path $WorkspaceRoot ".github"
$PromptsDir    = Join-Path $GithubDir "prompts"

# ─── Helpers ────────────────────────────────────────────────────────────────
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

# ════════════════════════════════════════════════════════════════════════════
# PHASE 1 — Global Plugin Install
# ════════════════════════════════════════════════════════════════════════════
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
        attrib +h $PluginRoot   # hide from Explorer
        Write-Ok "Plugin installed at $PluginRoot"
    }
} else {
    Write-Warn "Skipping plugin install (-SkipPluginInstall)"
    if (-not (Test-Path $PluginPath)) {
        Write-Error "Plugin not found at $PluginPath. Run without -SkipPluginInstall first."
        exit 1
    }
}

# ════════════════════════════════════════════════════════════════════════════
# PHASE 2 — Workspace Setup
# ════════════════════════════════════════════════════════════════════════════
Write-Step "Phase 2: Setting up workspace at $WorkspaceRoot"

New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null

# ── copilot-instructions.md ─────────────────────────────────────────────────
Set-FileContent (Join-Path $GithubDir "copilot-instructions.md") (Expand-Template @'
# GitHub Copilot — AI DevAgent Instructions

## Primary Agent

**You are the AI DevAgent Primary Implementation Agent.**

Read `__PLUGIN__\agents\primary-agent.agent.md` immediately. That file defines your complete operating model.

---

## Plugin Location

All agent framework files live in the plugin at:
```
__PLUGIN__
```

No copy of these files exists in the workspace. Always read from the plugin path above.

---

## Mandatory Startup — Execute Every Session

```
1. Read  __PLUGIN__\00-entrypoint.md
2. Read  .github\workspace-registry.md
3. Identify the target project from user input
4. Read  C:\Users\<you>\IdeaProjects\{project}\.github\ai-memory\00-index.md
5. Read  C:\Users\<you>\IdeaProjects\{project}\.github\ai-memory\project\p07-active-context.md
6. Load  task-specific project memory
```

If no `ai-memory` exists for the target project → Run `__PLUGIN__\workflows\project-discovery.md` first.

---

## Workspace Projects

See `.github\workspace-registry.md` in this workspace for the full project index and routing rules.

---

## Core Principles

- **AI-first**: Analyse, plan, implement, test, and review autonomously — escalate only for decisions requiring domain authority
- **Memory before code**: Always exhaust all memory layers before reading source code
- **Scope discipline**: Never modify files outside the affected module list from the plan
- **Plan required**: Never write code without a plan
- **Gate model**: Each workflow step (analyse → plan → implement → test → review → commit) is a gate — do not advance with unresolved blockers
- **No broad scans**: Never scan the full repository — use project memory for navigation

---

## Commands

When any command below is invoked, **immediately read the linked devagent prompt file and execute every step defined there**. Never skip steps or substitute with a summary.

| Command | Prompt File | DevAgent Source |
|---------|-------------|-----------------|
| `/analyse [task]` | `.github/prompts/analyse.prompt.md` | `__PLUGIN__\prompts\analyse.md` |
| `/plan [task]` | `.github/prompts/plan.prompt.md` | `__PLUGIN__\prompts\plan.md` |
| `/implement` | `.github/prompts/implement.prompt.md` | `__PLUGIN__\prompts\implement.md` |
| `/test` | `.github/prompts/test.prompt.md` | `__PLUGIN__\prompts\test.md` |
| `/review` | `.github/prompts/review.prompt.md` | `__PLUGIN__\prompts\review.md` |
| `/commit` | `.github/prompts/commit.prompt.md` | `__PLUGIN__\prompts\commit.md` |
| `/doall [task]` | `.github/prompts/doall.prompt.md` | `__PLUGIN__\prompts\doall.md` |
| `/propagate [task]` | `.github/prompts/propagate.prompt.md` | `__PLUGIN__\prompts\propagate.md` |
| `/optimize [file]` | `.github/prompts/optimize.prompt.md` | `__PLUGIN__\agents\code-optimizer.agent.md` |
| `/translate` | `.github/prompts/translate.prompt.md` | `__PLUGIN__\prompts\translate.md` |
| `/discover [project]` | `.github/prompts/discover.prompt.md` | `__PLUGIN__\workflows\project-discovery.md` |

---

## Knowledge Files (Generic)

Load only when project memory is silent:

- `__PLUGIN__\knowledge\architecture-patterns.md` — Design patterns
- `__PLUGIN__\knowledge\java-engineering.md` — Java 21 rules
- `__PLUGIN__\knowledge\data-access-patterns.md` — ORM, transactions
- `__PLUGIN__\knowledge\testing-strategies.md` — Test pyramid
- `__PLUGIN__\knowledge\api-error-handling.md` — REST, error handling
- `__PLUGIN__\knowledge\security-performance.md` — Security, caching

---

## Skill Files (Load per Task)

| Task | Load |
|------|------|
| Any Java code | `__PLUGIN__\skills\java-coding.md` |
| JPA / persistence | `__PLUGIN__\skills\jpa-persistence.md` |
| Spring services | `__PLUGIN__\skills\spring-framework.md` |
| DTOs | `__PLUGIN__\skills\dto-patterns.md` |
| Tests | `__PLUGIN__\skills\testing-guidelines.md` + junit5 + assertj + mockito |
| JavaFX | `__PLUGIN__\skills\javafx-client.md` |
| JMS messaging | `__PLUGIN__\skills\jms-messaging.md` |
| Maven | `__PLUGIN__\skills\maven-build.md` |
| Git | `__PLUGIN__\skills\git-workflow.md` |
| SQL | `__PLUGIN__\skills\sql-scripts.md` |
'@)

# ── workspace-registry.md ───────────────────────────────────────────────────
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

# ── prompt wrappers ─────────────────────────────────────────────────────────
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

Read the file `__PLUGIN__\workflows\project-discovery.md` and execute **every step** defined there exactly as written.

Do not summarise or skip steps. Follow the full discovery workflow.
'@
    }
}

foreach ($filename in $prompts.Keys) {
    $entry   = $prompts[$filename]
    $content = "---`n$($entry.frontmatter)---`n`n$(Expand-Template $entry.body)`n"
    Set-FileContent (Join-Path $PromptsDir $filename) $content
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " AI DevAgent — Installation Complete" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host " Plugin location  : $PluginPath" -ForegroundColor White
Write-Host " Workspace files  : $GithubDir" -ForegroundColor White
Write-Host ""
Write-Host " Next steps:" -ForegroundColor Yellow
Write-Host "   1. Edit .github\workspace-registry.md — add your projects"
Write-Host "   2. Open the workspace in IntelliJ"
Write-Host "   3. Use GitHub Copilot Chat — type /discover <project> to initialise a project"
Write-Host ""

# --- Script end-----------------------------------------