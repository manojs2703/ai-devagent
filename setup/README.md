# AI DevAgent — Setup

This folder is all you need to install and use the AI DevAgent with GitHub Copilot in IntelliJ.

---

## What This Does

- Installs the AI DevAgent plugin **once, globally** into a hidden folder on your machine
- Generates all required GitHub Copilot configuration files in your workspace
- Works across **multiple projects and workspaces** — run the installer once per workspace

---

## Prerequisites

| Tool | Required For |
|------|-------------|
| [Git](https://git-scm.com/) | Cloning the plugin |
| [PowerShell 5.1+](https://learn.microsoft.com/en-us/powershell/) | Running the install script (built into Windows 10/11) |
| [IntelliJ IDEA](https://www.jetbrains.com/idea/) | Your IDE |
| [GitHub Copilot plugin](https://plugins.jetbrains.com/plugin/17718-github-copilot) | AI assistant in IntelliJ |
| GitHub account with Copilot access | GitHub Copilot subscription |

---

## Installation

### Step 1 — Run the installer

Open PowerShell in your workspace root directory, then run:

```powershell
.\install.ps1
```

This does two things automatically:
1. Clones the plugin into `%USERPROFILE%\.ai-devagent\` (hidden, global — only runs once)
2. Creates `CLAUDE.md` and `.github\` configuration files in your current workspace

> If the plugin is already installed and you only need to set up a new workspace:
> ```powershell
> .\install.ps1 -SkipPluginInstall
> ```

> If your Copilot setup's Atlassian (Jira/Confluence) MCP tools use a different name prefix than
> the default `atlassian` (e.g. your tools are named `mcp_atlassian-vw_read_jira_issue`, so the
> prefix is `atlassian-vw`):
> ```powershell
> .\install.ps1 -AtlassianToolPrefix "atlassian-vw"
> ```
> This is workspace-specific and safe to change later by re-running with `-SkipPluginInstall`.

### Step 2 — Configure your workspace

Edit the generated `.github\workspace-registry.md` and add your projects, plus each project's
Jira project key and Confluence space key in the Atlassian Integration section:

```markdown
## Workspace Root
`C:\Users\yourname\path\to\workspace`

## Project Index
| # | Project ID | Root Path | Type |
|---|-----------|-----------|------|
| 1 | MyProject | `MyProject/` | Maven |

## Atlassian Integration (Jira / Confluence)
| Project ID | Jira Project Key | Confluence Space Key |
|-----------|-------------------|----------------------|
| MyProject | ABC               | ABCSPACE              |
```

The first time you run `/analyse` on a project, it discovers that project's actual Jira field
usage and Confluence page structure and caches it in
`{project}/.github/ai-memory/project/p06-atlassian-structure.md` — never in the plugin. Later
runs read that cache instead of rediscovering it every time.

### Step 3 — Install the GitHub Copilot plugin in IntelliJ

1. Open IntelliJ → **Settings** (`Ctrl+Alt+S`)
2. Go to **Plugins → Marketplace**
3. Search **GitHub Copilot** → Install → Restart IntelliJ
4. After restart: **Tools → GitHub Copilot → Login to GitHub**

### Step 4 — Open your workspace and verify

1. Open your workspace root in IntelliJ
2. Open **GitHub Copilot Chat** (right panel or `Alt+\`)
3. Type `/discover MyProject` — the agent will initialise AI memory for your project

---

## Adding Another Workspace

Just run the installer from the new workspace directory:

```powershell
cd C:\Dev\AnotherWorkspace
.\install.ps1 -SkipPluginInstall
```

---

## Keeping the Plugin Up to Date

```powershell
.\install.ps1 -SkipPluginInstall   # re-generate workspace files only
```

Or to pull the latest plugin version:

```powershell
.\install.ps1                      # pulls latest and refreshes workspace files
```

---

## What Gets Created

```
%USERPROFILE%\
└── .ai-devagent\               ← hidden, global plugin (do not edit)
    └── ai-devagent\
        ├── 00-entrypoint.md
        ├── agents\
        ├── workflows\
        ├── knowledge\
        ├── memory\
        ├── prompts\
        └── skills\

{WorkspaceRoot}\
├── CLAUDE.md                       ← Claude Code reads this automatically
└── .github\
    ├── copilot-instructions.md     ← Copilot reads this automatically
    ├── workspace-registry.md       ← Your project list (edit this)
    └── prompts\
        ├── analyse.prompt.md
        ├── plan.prompt.md
        ├── implement.prompt.md
        ├── test.prompt.md
        ├── review.prompt.md
        ├── commit.prompt.md
        ├── doall.prompt.md
        ├── propagate.prompt.md
        ├── optimize.prompt.md
        ├── translate.prompt.md
        └── discover.prompt.md
```

---

## Available Commands in Copilot Chat

| Command | What it does |
|---------|-------------|
| `/discover [project]` | Initialise AI memory for a new project |
| `/analyse [task]` | Analyse a story or task before coding |
| `/plan [task]` | Create a development plan |
| `/implement` | Implement code (plan must exist) |
| `/test` | Write and verify tests |
| `/review` | Review code changes |
| `/commit` | Prepare a commit message |
| `/doall [task]` | Full workflow end-to-end |
| `/propagate [task]` | Decompose a task into subtasks |
| `/optimize [file]` | Optimise a file for quality and performance |
| `/translate` | Translate terms between languages/domains |

---

## Troubleshooting

**Copilot does not pick up the instructions**
- Make sure IntelliJ is opened at the workspace root (the folder containing `.github\`)
- Restart IntelliJ after installing the Copilot plugin

**Install script fails with access denied**
- Run PowerShell as Administrator for the first install

**Plugin update fails**
- Check that you still have access to the private plugin repository
