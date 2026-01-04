---
name: verify-implementation
description: "Guidelines for automated and manual verification of code changes. When to use: - After making code changes to ensure correctness As part of the implementation workflow"
---

# Verify Implementation

Perform mandatory verification of implementation before completion.

## 1. Preflight checks

- Run linting, formatting, type-checking
- Rectify issues before proceeding

## 2. Verify functionality

**Automated verification:**
- Run relevant tests (unit/integration)
- Focus on changed areas, avoid full suite

**Manual verification:**
- CLI output, UI checks, database verification
- For browser work: use DevTools, save screenshots to `artefacts/`

