# Prompt: Translate — Generic Workflow

**Purpose**: Translate technical terms between languages or between business and technical language.
**Common use**: German ↔ English domain terms, business concept ↔ technical implementation.

---

## Context Loading

```
1. active-context.md       → current project context
2. domain-concepts.md      → project domain glossary (check project memory)
```

---

## Translation Types

### Business → Technical
Map business language to code artifacts:
- A business term → entity class, service interface, DTO
- Example: "Customer" → `Customer` entity, `CustomerFassade` service interface

### Technical → Business
Explain technical concepts in business language:
- `@Transactional` → "ensures all changes in a business operation are saved together or not at all"
- N+1 query problem → "loads one item, then separately loads each related item — 100 DB calls instead of 1"

### Cross-Language Glossary
For domain terms, output:

| Source Term | Target Term | Technical Artifact | Notes |
|-------------|-------------|-------------------|-------|

---

## Output Rules

- Use the project's canonical glossary first (check project memory `domain-concepts.md`)
- If no project definition exists, use the generic term and note it
- For EPL projects: also check `.github/prompts/translate.prompt.md` for the domain glossary

---

## Memory Update

If a new domain term is translated and confirmed:
- Add to `domain-concepts.md` in project memory
- Include: source term, target term, technical class name, notes

