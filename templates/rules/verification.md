---
name: verification
description: Evidence-based validation ladder and verification gate before completion.
trigger: model_decision
---

# Verification & Completion Gate Rules

## 1. The Iron Law of Verification
- **NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**
- Never state that code is "fixed", "passing", or "complete" without executing the relevant validation command in this turn.
- Confidence or intuition is not a substitute for test, build, or linter output.

## 2. Proportional Validation Ladder
- **Isolated Edit**: Run the specific unit test or fast check directly covering the modified function.
- **Module Edit**: Run module test suite and static typecheck/lint.
- **Cross-Cutting Change**: Run integration/E2E test suite and complete project build.
- **Physical/UI/Hardware Changes**: When automated tests cannot fully verify behavior (e.g. video capture, desktop windowing), explicitly output `TESTE MANUAL NECESSÁRIO` with a clear, step-by-step reproduction checklist.
