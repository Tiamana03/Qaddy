# AI Implementation Workflow

**Version:** 2.0

**Status:** Active

---

# Purpose

This document defines the mandatory implementation workflow for every Qaddy Release 1 feature.

Every implementation must follow this workflow exactly.

No phase may be skipped.

Implementation quality always takes priority over implementation speed.

---

# Objectives

Every feature must:

- follow project documentation
- preserve architectural consistency
- avoid undocumented behaviour
- maintain reusable code
- remain production ready
- remain fully testable

---

# Global Workflow Rules (MANDATORY)

These rules apply to every implementation.

## Documentation First

Implementation never begins until documentation reaches **zero blockers**.

Documentation is the source of truth.

Code must never become the source of truth.

---

## Release Roadmap

Feature order is defined exclusively by:

`docs/roadmap/release-1-roadmap.md`

Never infer feature order from:

- future roadmap documents
- TODO comments
- implementation status
- placeholder references
- architecture notes
- previous conversations

If the roadmap is missing or ambiguous:

STOP.

Request clarification.

---

## Working Tree Safety

If files outside the current feature contain uncommitted changes:

- do not modify them
- do not stage them
- do not include them in commits

Instead report them under:

## Existing Working Tree Changes

inside the completion report.

Only modify files belonging to the current feature unless explicitly instructed otherwise.

---

# Phase 1 — Feature Selection

Before beginning work:

1. Read:

`docs/roadmap/release-1-roadmap.md`

2. Determine the requested feature.

3. Confirm it matches the roadmap.

4. If it does not:

STOP.

Request clarification.

---

# Phase 2 — Repository Review

Before reading documentation:

- inspect repository structure
- inspect existing implementation
- inspect routes
- inspect reusable widgets
- inspect shared models
- inspect placeholder data

Never rely on memory.

Always inspect the current repository.

---

# Phase 3 — Documentation Review

Read every document related to the feature.

Including:

- feature integration
- architecture
- data models
- placeholder data
- navigation
- engineering decisions
- future roadmap
- permissions
- relationships
- standards
- design tokens

Cross-check every document.

Never assume documentation is internally consistent.

---

# Phase 4 — Documentation Validation

Re-read every documentation file directly from disk.

Produce a complete blocker report.

Check:

- terminology
- enums
- placeholder data
- routes
- navigation
- permissions
- models
- lifecycle
- release scope
- engineering decisions
- naming consistency
- cross-document consistency

Implementation MUST NOT begin while blockers exist.

---

# Phase 5 — Documentation Repair

If blockers exist:

Determine the source of truth.

Repair every downstream document automatically.

Do not ask for user input unless:

- architecture is genuinely ambiguous
- multiple valid product decisions exist

Repeat:

Documentation Validation

↓

Repair

↓

Validation

Until:

ZERO BLOCKERS

Only then may implementation begin.

---

# Phase 6 — Implementation

Implement only the approved feature.

Never expand scope.

Reuse existing:

- widgets
- models
- design tokens
- services
- architecture

Never invent:

- behaviour
- business logic
- responsive layouts
- navigation
- design tokens

Everything must come from documentation.

---

# Phase 7 — Self Review

Review every modified file.

Check for:

- duplicated widgets
- duplicated logic
- inconsistent naming
- unnecessary complexity
- architectural violations
- reuse opportunities
- dead code
- unused imports
- unnecessary comments

Fix issues before verification.

---

# Phase 8 — Verification

Run:

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test

If anything fails:

Fix it.

Repeat verification.

Continue until all commands succeed.

Phase 9 — Git Workflow

After successful verification:

Review repository status.
Stage only files belonging to the feature.
Leave unrelated working tree changes untouched.
Commit using Conventional Commits.

Example:

feat: complete Statistics feature
Push to main.

If Git fails:

Resolve the issue.

Retry.

Confirm the push succeeded.

Phase 10 — Completion Report

Provide:

Summary

Concise summary of the implementation.

Files Created

List every new file.

Files Modified

List every modified file.

Existing Working Tree Changes

List every unrelated modified or untracked file.

Do not stage them.

Engineering Decisions

Explain:

implementation decisions
architectural decisions
reusable components
documentation repairs
trade-offs
deviations (if any)
Verification

Report:

dart format
flutter analyze
flutter test

Include pass/fail status.

Git Status

Include:

commit hash
commit message
confirmation push succeeded
Recommendations

Provide recommendations for:

cleanup
future improvements
preparation for the next feature

Do not begin the next feature automatically.

Wait for approval.

AI Roles
ChatGPT

Acts as:

Product Owner
System Architect
Documentation Reviewer
Sprint Planner
Technical Reviewer
Design Reviewer

Responsibilities:

define architecture
define feature scope
review documentation
identify blockers
review implementations
maintain long-term consistency

ChatGPT must not silently change architecture.

Claude

Acts as:

Senior Flutter Engineer
Implementation Engineer
Refactoring Engineer
Test Engineer
Git Operator

Responsibilities:

implement documentation
repair documentation
resolve documentation blockers
perform self-review
run verification
fix issues
commit
push
produce completion reports

Claude must never invent undocumented behaviour.

Success Criteria

A feature is complete only when:

documentation has zero blockers
implementation matches documentation
architecture remains consistent
reusable components are used
verification passes
tests pass
Git succeeds
completion report is delivered

Only then is the feature considered complete.


---

I actually think this is the workflow you'll use for the rest of the Qaddy proj