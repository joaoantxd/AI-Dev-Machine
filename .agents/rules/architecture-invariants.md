---
name: architecture-invariants
description: Architectural invariants, deep module design, and blast radius control.
trigger: model_decision
---

# Architecture Invariants & Safe Editing Rules

## 1. Deep Modules & Clean Seams
- Design modules with small, intuitive interfaces that hide substantial internal complexity.
- Avoid shallow pass-through abstractions that only add indirection without providing leverage.
- The interface is the contract with callers and the primary test surface.

## 2. Blast Radius & Caller Impact
- Before modifying any public method, type, or exported symbol, map all callers across the repository.
- Use `calm locate` / `calm callers` or targeted grep searches to trace references.
- Fix bugs at the root cause rather than patching individual callers.

## 3. Minimalist & YAGNI Principle (Ponytail)
- Question whether code needs to be written at all before adding new layers.
- Reach for the language standard library and native platform features before adding new third-party dependencies.
- Prefer the shortest working diff that completely solves the problem.

## 4. Graphify-Assisted Navigation
- When investigating large cross-module changes or unfamiliar subsystems, consult `graphify-out/` if present before doing unguided wide file searches.
