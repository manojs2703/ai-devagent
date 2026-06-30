# Master Prompt: Generate Project Overview

**CRITICAL INSTRUCTIONS**:
- ⚠️ **AVOID generating PowerShell commands for the user to execute!** Use your tools (`file_search`, `list_dir`, `read_file`, etc.) DIRECTLY!
- Do NOT try to create `specific-project-setup.md` as a new file - it already exists and must be overwritten!
- **Generate ALL content in ENGLISH** — descriptions, comments, documentation

Analyze the source code of the target project, populate/create files, and update the SPECIFIC block in the configuration files.

**Important**: This master prompt works for ANY project in the workspace. First identify the project root directory before proceeding.

---

## Output Structure — 3-File Hierarchy for Token Optimization

This master prompt generates **multiple output files** with a hierarchical structure to minimize token usage:

1. **`specific-project-setup.md`** — Technology stack overview (SPECIFIC block)
2. **`specific-project-details.md`** — **CORE** module reference (~1,200 tokens)
3. **`modules/{module-name}.md`** — **MODULE DETAILS** per module (~300-600 tokens each)
4. **`specific-libraries.md`** — **LIBRARIES** complete list (~2,000 tokens)

**Token Optimization Strategy**: Most workflow tasks only load the core file. Module files are loaded individually on-demand for specific modules. This reduces typical token usage from ~5,500 to ~1,200 per workflow task (78% reduction). When module details are needed, only relevant modules are loaded (not all modules).

**Design Principle**: Module files contain ONLY technical content. Their purpose and usage context is described in the core file that links to them, avoiding redundancy.

---

## Output 1: `specific-project-setup.md` (populate existing file)

**Goal**: Project-specific guidelines that flow into the SPECIFIC block of `CLAUDE.md` / `copilot-instructions.md`.

**Note**: This file already exists as an empty template in the project's `.github/workflow/specific-project-setup.md`. **Populate** (overwrite) it with the content below.

**Format**:

```markdown
# Project-Specific Guidelines

## Project Context

**Project**: `<artifactId>` — <description from pom.xml - IN ENGLISH>
**Group ID**: `<groupId>`
**Java**: <version>
**Build**: Maven Multi-Module (<n> modules: <comma-separated module list>)

### Project Focus

<2-3 sentences on the functional purpose of the project — derived from pom.xml description or README - IN ENGLISH>

### Root Package

`<root-package>.*`

### Documentation Structure

**Project context files** (hierarchical loading for token optimization):
- `.github/workflow/specific-project-details.md` — **CORE** reference (module overview with links, frameworks, patterns) — load for most tasks
- `.github/workflow/modules/{module-name}.md` — **MODULE DETAILS** (one file per module: detailed descriptions, packages) — load specific modules on-demand
- `.github/workflow/specific-libraries.md` — **LIBRARIES** complete list — load for dependency tasks
```

---

## Output 2: `specific-project-details.md` (create new file - CORE)

**Goal**: Lightweight module reference for daily workflow tasks (analyse, plan, commit)

**Target**: ~1,200 tokens (~100 lines)

**Note**: This file does NOT exist yet. Create it at the project's `.github/workflow/specific-project-details.md`.

**Format**:

```markdown
# Project Details - {Project Name}

## Modules (Quick Reference)

### {module-name}
**Purpose**: {One-line purpose - IN ENGLISH}
**Key Responsibilities**: {3-5 key bullet points - IN ENGLISH}
**Main Packages**: `package.name.*` (wildcard notation)
**📄 Detailed Documentation**: `.github/workflow/modules/{module-name}.md`

{Repeat for ALL modules, sorted alphabetically}

---

## Key Frameworks

- **{Framework Name}**: {One-line purpose/role - IN ENGLISH}
{List 5-10 most important frameworks}

---

## Common Patterns

- **{Pattern Name}**: {Usage/context - IN ENGLISH}
{List 3-5 architectural or coding patterns specific to this project}

---

**Note**: For detailed module information, see the respective module file in `.github/workflow/modules/`
**Note**: For the complete library list, see `specific-libraries.md`
```

**Guidelines**:
- Module section: Name + one-line purpose + 3-5 key responsibilities + main package(s) with wildcards ONLY
- NO detailed descriptions, NO complete class lists, NO libraries
- Keep it lightweight — ~10 lines per module maximum

---

## Output 3: `modules/{module-name}.md` (create new files - MODULE DETAILS)

**Goal**: Detailed module information for complex tasks (refactorings, architectural decisions, unknown areas)

**Target**: ~300-600 tokens per module file

**Note**: This file does NOT exist yet. Create it at the project's `.github/workflow/modules/{module-name}.md`.

**Format**:

```markdown
# Module: {module-name}

**Purpose**: {One-line purpose - IN ENGLISH}

---

## Detailed Description

{Full multi-paragraph description (3-5 paragraphs) of the module's:
- Functional responsibilities
- Architecture and design patterns
- Integration with other modules
- Key business logic
- Technical implementation details}

---

## Key Packages

- **`package.name.subpackage`** - {Description}: `ClassName1`, `ClassName2`, `ClassName3`, ...
{Complete list of ALL important packages with ALL relevant class names for THIS module}

---

**Dependencies**: See `specific-libraries.md` for external libraries
**Back to overview**: `.github/workflow/specific-project-details.md`
```

**Guidelines**:
- **Create one separate file per module** (not one file with all modules)
- Each file: Full detailed description (3-5 paragraphs) + complete package list for THAT module
- NO libraries — they go in Output 4
- Example file names: `app-server.md`, `client.md`, etc.

---

## Output 4: `specific-libraries.md` (create new file - LIBRARIES)

**Goal**: Complete library list for dependency-related tasks

**Target**: ~2,000 tokens (~120 lines)

**Note**: This file does NOT exist yet. Create it at the project's `.github/workflow/specific-libraries.md`.

**Format**:

```markdown
# Project Libraries

**Purpose**: Complete list of all external dependencies

**When to use this file**:
- Dependency updates and version management
- Evaluating alternatives or adding new libraries
- CVE security checks
- Troubleshooting build/dependency conflicts

**For daily workflow tasks**: Libraries are rarely needed — use core/module files instead.

---

## Frameworks & Core Technologies

- **`artifact-id`** (`version X.Y`) - {Description - IN ENGLISH}
{Group Spring, JavaFX, and other core frameworks here}

## VW-Internal Frameworks

- **`artifact-id`** - {Description - IN ENGLISH}
{List Petrichor, Samsara, Beppo, Kairos, etc. — all VW-internal frameworks}

## Data Access & Persistence

- **`artifact-id`** - {Description - IN ENGLISH}

## Messaging

- **`artifact-id`** - {Description - IN ENGLISH}

## Utilities & Helpers

- **`artifact-id`** - {Description - IN ENGLISH}

## JSON & XML

- **`artifact-id`** - {Description - IN ENGLISH}

## Validation

- **`artifact-id`** - {Description - IN ENGLISH}

## Logging

- **`artifact-id`** - {Description - IN ENGLISH}

## Testing

- **`artifact-id`** - {Description - IN ENGLISH}

{Additional categories as needed}

---

**Note**: For module and package information, see `specific-project-details.md` (core) and `modules/{module-name}.md` (individual module details)
```

**Guidelines**:
- **Complete list** of all external libraries from parent-pom.xml and module POMs
- Exclude: JDK standard libraries, Lombok, SLF4J (those are in generic setup)
- Group by functional category
- Include version numbers where relevant

---

## Important: Use Tools Directly - NO Manual Commands!

**CRITICAL**: Do NOT generate PowerShell commands that require user confirmation! Instead, use your available tools directly:

### ✅ Correct Approach - Use Tools Directly:

- **File reading**: Use `read_file` tool to read pom.xml, source files, etc.
- **Directory listing**: Use `list_dir` tool to explore folder structures
- **File search**: Use `file_search` tool to find files by pattern (e.g., `**/*.java`, `**/pom.xml`)
- **Content search**: Use `grep_search` tool to search for patterns in files
- **File operations**: Use `create_file`, `replace_string_in_file`, or `insert_edit_into_file` tools
- **Directory creation**: Use `create_file` tool - it automatically creates missing parent directories! There is NO need to manually create directories with PowerShell commands.

### ❌ Wrong Approach - Avoid These:

- ❌ Do NOT use `run_in_terminal` with `Get-ChildItem`, `Select-Object`, `ForEach-Object`
- ❌ Do NOT use `run_in_terminal` with `New-Item -ItemType Directory` - `create_file` creates directories automatically!
- ❌ Do NOT generate PowerShell scripts that need user confirmation
- ❌ Do NOT ask the user to manually run commands or create directories

### Example Workflow:

**Instead of**:
```powershell
Get-ChildItem -Path "...\src\main\java" -Recurse -Directory | ...
```

**Use**:
1. `file_search` with pattern `**/src/main/java/**/*.java` to find all Java files
2. Analyze the file paths to extract package names
3. Use `list_dir` to explore specific directories if needed
4. Use `read_file` to read Java class files and extract information

---

## Procedure

1. **Identify the project root**:
   - Ask the user which project to analyze, or determine from context
   - The project root is a subdirectory of the workspace (e.g., `epl_ps/`, `epl_an/`, etc.)

2. **Capture project structure**:
   - Use `read_file` to read root `pom.xml`: groupId, artifactId, description, Java version, modules
   - Use `file_search` with pattern `**/README.md` to find README if present
   - Use `read_file` to read README content

3. **Consolidate libraries** (for Output 4):
   - Use `file_search` with pattern `**/pom.xml` to find all POM files
   - Use `read_file` to read parent-pom.xml and all module POMs
   - Consolidate external dependencies into a complete, categorized list
   - Exclude: JDK standard libraries, cross-cutting libraries (Lombok, SLF4J)

4. **Analyze modules** (one by one, sorted alphabetically):
   - Use `file_search` with pattern `**/<module-name>/src/main/java/**/*.java` to find Java files per module
   - Use `list_dir` to explore package structure under `src/main/java`
   - Use `read_file` to read main classes, entry points, core concepts
   - For Output 2 (core): Extract purpose, key responsibilities, main packages (wildcards)
   - For Output 3 (individual module details): Full detailed descriptions + complete package/class lists
   - Dependencies on other modules can be extracted from module POMs

5. **Populate `specific-project-setup.md`** (Output 1):
   - Location: `{project}/.github/workflow/specific-project-setup.md`
   - **The file already exists** — use `replace_string_in_file` or `create_file` to overwrite it completely
   - **No libraries** — only project metadata and references to the 3 detail files

6. **Create `specific-project-details.md`** (Output 2 - CORE):
   - Location: `{project}/.github/workflow/specific-project-details.md`
   - Use `create_file` to **create this new file**
   - Target: ~100 lines, ~1,200 tokens
   - Modules (quick reference) + frameworks + patterns

7. **Create `modules/{module-name}.md`** (Output 3 - MODULE DETAILS):
    - Location: `{project}/.github/workflow/modules/{module-name}.md`
    - Use `create_file` to **create this new file** (the tool automatically creates the `modules/` directory if it doesn't exist)
    - **IMPORTANT**: `create_file` handles directory creation automatically - do NOT manually create directories with PowerShell commands!
    - Target: ~300-600 tokens per module file
    - Modules (detailed descriptions + complete package lists)

8. **Create `specific-libraries.md`** (Output 4 - LIBRARIES):
   - Location: `{project}/.github/workflow/specific-libraries.md`
   - Use `create_file` to **create this new file**
   - Target: ~120 lines, ~2,000 tokens
   - Complete categorized library list

9. **Update SPECIFIC block**:
   - Use `read_file` to read the content of the populated `specific-project-setup.md`
   - Use `file_search` to find `**/CLAUDE.md` and `**/.github/copilot-instructions.md` within the project
   - Use `replace_string_in_file` to replace the area between
     `<!-- BEGIN:AI-WORKFLOW-SPECIFIC -->` and `<!-- END:AI-WORKFLOW-SPECIFIC -->`
     with the content from `specific-project-setup.md`

10. **Verify generated files automatically**:
    - Use `file_search` to find all created files (`specific-project-details.md`, `modules/*.md`, `specific-libraries.md`)
    - Use `read_file` to read each generated file and verify:
      - Module files have no "When to use this file" or "For daily workflow tasks" blocks
      - Module files contain: Purpose, Detailed Description, Key Packages, cross-references
      - Token counts are reasonable (estimate from character count)
    - Report the verification results to the user with file paths and basic statistics

---

## After Generation — Verification Steps

1. **Verify all 4 files created**:
   - ✅ `specific-project-setup.md` (exists, updated)
   - ✅ `specific-project-details.md` (created, ~100 lines)
   - ✅ `modules/{module-name}.md` (created, one file per module)
   - ✅ `specific-libraries.md` (created, ~120 lines)

2. **Verify token targets**:
   - Core file: ~1,200 tokens (80-120 lines)
   - Each module file: ~300-600 tokens per file
   - Libraries file: ~2,000 tokens (100-150 lines)

3. **Verify cross-references**:
   - Core file → **links to each module file** via `**📄 Detailed Documentation**: .github/workflow/modules/{module-name}.md`
   - Each module file → links back to core + mentions libraries file
   - Libraries file → mentions core and module files
   - Setup file → documents the hierarchical structure

4. **Verify hierarchical structure**:
   - Core file is LIGHTWEIGHT (no detailed descriptions, no class lists, no libraries)
   - Module files have DETAILED descriptions + complete package lists (but no libraries)
   - Libraries file has ONLY libraries (no module descriptions)

5. **SPECIFIC block updated**: Both `CLAUDE.md` and `.github/copilot-instructions.md` (in the project) contain the new content

---

## Quality Criteria

- ✅ **ALL content in ENGLISH** — descriptions, documentation, comments
- ✅ No invented content — everything derived from the code
- ✅ Class names correct and extracted from the code
- ✅ **Module-file hierarchy maintained**:
  - Core: lightweight module overview with **explicit links to each module file**, daily use
  - Module files: detailed per-module documentation, load on-demand (linked from core)
  - Libraries: complete list, rarely needed
- ✅ **Token targets met**:
  - Core: ~1,200 tokens
  - Each module file: ~300-600 tokens
  - Libraries: ~2,000 tokens
- ✅ **Cross-references present**: 
  - Core has `**📄 Detailed Documentation**: .github/workflow/modules/{module-name}.md` for EACH module
  - Module files link back to core and mention libraries
  - Libraries file mentions core
- ✅ **No libraries** in core or module files — they belong ONLY in the libraries file
- ✅ **One file per module**: Each module has its own dedicated detail file in `modules/` directory
- ✅ **Links are mandatory**: Every module entry in core MUST have a link to its detail file
- ✅ SPECIFIC block in `CLAUDE.md` and `.github/copilot-instructions.md` updated after the run

