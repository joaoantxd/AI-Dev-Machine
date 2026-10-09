# AGENTS.md — [PROJECT_NAME]

> **Universal Agent Constitution & Operating Invariants**
> Keep this root constitution concise and universal. Detailed domain guidance lives in `.agents/rules/`, `.agents/skills/`, and `.agents/agents/` and is discovered on demand.

---

## 1. Immutable Invariants

1. **Security & Secrets**: Never commit or expose API keys, tokens, credentials, private keys, or `.env` files.
2. **Safety & Working Tree**: Never execute destructive operations (`DROP`, `TRUNCATE`, `git push --force`, `rm -rf`) without explicit authorization. Preserve the user's uncommitted working tree.
3. **Evidence-Based Completion**: Never declare a task complete, fixed, or passing without fresh validation evidence (tests, build, typecheck, or command output).
4. **Deep Modules & YAGNI**: Prefer the standard library, reuse existing utilities, and keep interfaces small and cohesive. Avoid speculative abstractions.
5. **Automatic Skill & Progressive Routing**: Identify and load relevant domain skills (`view_file` on `SKILL.md`) at the start of non-trivial tasks before executing ad-hoc searches or edits. Never bulk-load unrelated skills.

---

## 2. Project Metadata & Stack

- **Project Name**: [PROJECT_NAME]
- **Description**: [PROJECT_DESCRIPTION]
- **Profile**: [PROJECT_PROFILE]
- **Primary Runtime / Language**: [PROJECT_RUNTIME]
- **Target OS**: Windows

---

## 3. Canonical Commands

```bash
# Install dependencies
[CMD_INSTALL]

# Run development server / app
[CMD_DEV]

# Run tests
[CMD_TEST]

# Typecheck / Static Analysis
[CMD_TYPECHECK]

# Lint / Format
[CMD_LINT]

# Build / Compile
[CMD_BUILD]
```

---

## 4. Workflows & Progressive Disclosure

- **Architecture Discovery & Cross-Module Impact**: Use Graphify (`graphify query`) when `graphify-out/` is present, or CALM for call graph analysis.
- **Bugs & Regressions**: Activate `systematic-debugging` or `diagnosing-bugs`.
- **UI & Web Craft**: Consult `ui-ux-pro-max`, `frontend-design`, or `impeccable`.
- **Database & Supabase**: Consult `supabase-postgres-best-practices`.
- **Cognitive Delegation**:
  - Delegate deep read-only codebase mapping to `researcher`.
  - Delegate independent code & spec review to `reviewer`.
  - Delegate security audits to `security-reviewer`.

---

## 5. Completion Checklist

- [ ] Code compiles and typecheck passes.
- [ ] Relevant unit / integration tests pass.
- [ ] No secrets or unwanted files in `git status`.
- [ ] `TESTE MANUAL NECESSÁRIO` declared if human hardware/visual verification is required.
