# Workspace Registry

**Purpose**: Central index of all projects managed by the AI DevAgent in this workspace.
**Used by**: `primary-agent.agent.md` for project routing.

---

## Workspace Root

`C:\Users\sathym\IdeaProjects\`

---

## Project Index

| # | Project ID | Root Path | Type | AI Memory | Status |
|---|-----------|-----------|------|-----------|--------|
| 1 | EPL-Project | `EPL-Project/` | Maven Multi-Module (Java) | Not initialized | Active |
| 2 | Evps-Project | `Evps-Project/` | TBD | Not initialized | Active |

---

## EPL-Project

**Root**: `EPL-Project/`
**Type**: Maven Multi-Module Java Enterprise Application
**Jira Prefix**: EPL-
**Keywords**: EPL, epl, epl_

### Key Sub-Projects

| Sub-Project | Path | Notes |
|-------------|------|-------|
| epl (core) | `EPL-Project/epl/` | Core multi-module Maven app |
| epl_super_pom | `EPL-Project/epl_super_pom/` | Parent POM / BOM |
| epl_bom | `EPL-Project/epl_bom/` | Dependency management |
| epl_dto | `EPL-Project/epl_dto/` | Data Transfer Objects |
| epl_api | `EPL-Project/epl_api/` | API layer |
| epl_basis | `EPL-Project/epl_basis/` | Base/foundation |
| epl_common_services | `EPL-Project/epl_common_services/` | Shared services |
| epl_fachliche_module | `EPL-Project/epl_fachliche_module/` | Business/domain modules |
| epl_job_execution | `EPL-Project/epl_job_execution/` | Job execution |
| epl_remote_services | `EPL-Project/epl_remote_services/` | Remote services |
| epl_an / epl_ap / epl_im / epl_jm / epl_mg / epl_ps / epl_pu / epl_rs / epl_vb | various | Domain modules |
| test-annotations | `EPL-Project/test-annotations/` | Custom test annotations |
| vwcommons / vwcommons-test / vwcommonsgui | various | VW commons libraries |
| petrichor / samsara | various | Internal frameworks |

**Scope note**: OpenAPI implementation tasks are allowed across `EPL-Project` subprojects except `epl`, where OpenAPI must not be used.

**Bootstrap**: Run `/discover EPL-Project` to initialize AI memory.

---

## Evps-Project

**Root**: `Evps-Project/`
**Type**: TBD — needs project discovery
**Keywords**: EVPS, Evps, evps

**Bootstrap**: Run `/discover Evps-Project` to initialize AI memory.

---

## Routing Rules

| User input contains | Target project |
|--------------------|----------------|
| "EPL", "epl_", "EPL-NNN" | EPL-Project |
| "EVPS", "evps_" | Evps-Project |
| Explicit path | Use exact path |
| Unclear / multiple | Ask user to clarify |

---

## Adding a New Project

1. Add a row to the Project Index table
2. Add a dedicated section with sub-project details
3. Add routing keywords to Routing Rules
4. Run `/discover {project}` to initialize AI memory
5. Update status column after discovery completes

