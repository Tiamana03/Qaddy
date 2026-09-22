# AI Implementation Workflow

**Version:** 1.0

**Status:** Active

---

# Purpose

This document defines the mandatory implementation workflow for every Qaddy sprint.

All AI assistants working on this repository must follow this workflow.

No implementation may skip any step.

---

# Objectives

Every sprint must:

- follow the project documentation
- preserve architectural consistency
- avoid undocumented decisions
- remain fully testable
- maintain production quality

Quality is always more important than speed.

---

# Phase 1 — Pre-Implementation Review

Before writing any code:

1. Read the sprint document completely.

2. Read every referenced document.

3. Read every referenced design token.

4. Cross-check the current repository.

5. Verify existing implementations.

Never assume previous knowledge.

Always re-read the documentation.

---

# Phase 2 — Architecture Validation

Before implementation, verify:

- documentation is complete
- behaviour is fully specified
- design tokens exist
- referenced classes exist
- repository structure matches documentation
- implementation does not conflict with existing code

---

# Phase 3 — Blocker Review

If anything is unclear:

STOP.

Do not implement.

Instead provide:

- Blocker
- Why implementation requires guessing
- Which document should be updated
- Recommendation (if applicable)

Never invent:

- design decisions
- responsive behaviour
- design tokens
- component behaviour
- architecture
- business logic

Implementation only begins after blockers are resolved.

---

# Phase 4 — Implementation

Implement only what exists within the sprint scope.

Do not expand scope.

Do not begin future sprints.

Follow:

- project-rules.md
- engineering-principles.md
- architecture documents
- design tokens

Every implementation must:

- use existing design tokens
- remain reusable
- remain production ready
- follow Flutter best practices

---

# Phase 5 — Self Review

Before verification:

Review every file created or modified.

Check for:

- duplicated logic
- unnecessary complexity
- unused code
- inconsistent naming
- architectural violations
- opportunities for simplification

Fix issues before continuing.

---

# Phase 6 — Verification

Run exactly:

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test

If any command fails:

fix the issue
rerun verification
repeat until all commands pass

Do not continue until verification succeeds.

---

# Phase 7 — Git Workflow

After successful verification:

1. Check repository status.

2. Stage all sprint changes.

3. Commit using an appropriate Conventional Commit message.

Example:

```text
feat: complete Sprint 1.5 app shell and navigation
```

4. Push to the main branch.

If Git reports any errors:

- resolve the issue
- rerun the Git commands
- confirm the push succeeded

Do not leave the repository in a partially committed state.

---

# Phase 8 — Completion Report

Finish every sprint by providing the following report.

## Summary

Provide a concise summary of what was implemented.

---

## Files Created

List every new file created during the sprint.

---

## Files Modified

List every existing file modified during the sprint.

---

## Engineering Decisions

Explain any implementation decisions including:

- unavoidable prerequisites
- architectural considerations
- implementation trade-offs
- corrections made during development

If an implementation differed from the original plan, explain why.

---

## Verification

Report the results of:

- dart format
- flutter analyze
- flutter test

Include whether all checks passed successfully.

---

## Git Status

Include:

- commit hash
- commit message
- confirmation that the push to main succeeded

---

## Recommendations

Provide recommendations for improving the project or preparing the next sprint.

Do not begin the next sprint.

Wait for review and approval.

---

# AI Roles

## ChatGPT

ChatGPT acts as:

- Product Owner
- System Architect
- Sprint Planner
- Documentation Reviewer
- Design Reviewer
- Technical Reviewer

Responsibilities:

- define sprint scope
- review documentation
- identify blockers
- review implementations
- improve architecture
- ensure long-term consistency

ChatGPT should not silently change product direction or architecture during implementation.

---

## Claude

Claude acts as:

- Senior Flutter Engineer
- Implementation Engineer
- Refactoring Engineer
- Test Engineer
- Git Operator

Responsibilities:

- implement sprint documentation
- keep code production-ready
- run verification
- fix implementation issues
- commit changes
- push changes
- produce completion reports

Claude must not invent undocumented behaviour or architecture.

---

# General Rules

Always:

- read documentation before implementation
- verify the current repository state
- follow project rules
- follow architecture documents
- use design tokens
- write reusable code
- write production-quality Flutter code
- keep code simple and maintainable
- document engineering decisions

Never:

- invent undocumented behaviour
- invent design tokens
- hardcode design values
- skip verification
- skip Git
- silently change architecture
- expand sprint scope
- begin the next sprint without approval

When documentation and implementation conflict:

Stop immediately.

Report the conflict.

Identify which document requires updating.

Wait until the documentation has been corrected before continuing.

---

# Success Criteria

A sprint is only considered complete when:

- implementation matches the sprint documentation
- architecture remains consistent
- all verification commands pass
- all tests pass
- code is production-ready
- Git commit succeeds
- Git push succeeds
- the completion report has been delivered

Only then is the sprint considered complete.