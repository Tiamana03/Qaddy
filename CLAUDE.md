# Qaddy — Claude Code guide

This repository is the Qaddy production Flutter app. The app's engineering guide follows; its reading order refers to files in `docs/`.

@docs/CLAUDE.md

## Two repositories, one project

| Repository | Local path | Source of truth for |
|---|---|---|
| Qaddy (this repo) | `C:\Qaddy` | Everything needed to build, maintain and ship the Flutter app: product and feature specs, UI/UX, design system, Flutter architecture, state management, navigation, widgets and components, Supabase integration, database models used by the app, Flutter sprint planning, app-only ADRs |
| qaddy-devtools | `C:\Developer\qaddy-devtools` | GolfCore integration, course auditing, the import pipeline, Python tooling, migration scripts, automation, CI/CD, engineering workflows, cross-repository architecture, platform docs, ADRs that affect both repositories |

Document ownership:

- A document that affects only one repository lives in that repository.
- A document that affects both repositories has its master copy in qaddy-devtools. This repository links to it instead of duplicating it.
- Before creating or editing any document, decide which repository owns it. If that is unclear, stop and ask.
- Qaddy's existing documentation stays here. Do not migrate it to qaddy-devtools.

## Flutter work

1. Read the relevant docs in this repository first. `docs/README.md` is the index.
2. If the feature depends on tooling or shared architecture (for example course data imported from GolfCore, or Supabase data that the tools write), also read the relevant docs in `C:\Developer\qaddy-devtools\docs`.
3. Implement the Flutter code here.
4. If the work changes shared architecture or tooling, propose documentation updates for qaddy-devtools. Make them only after the user approves.

## Rules

- **Docs need approval.** Change files under `docs/` here, or anything in qaddy-devtools, only after the user approves that specific change in chat. Propose first: which file, and what changes.
- **No tooling here.** Developer tooling (importers, audits, migration scripts, automation, CLIs) belongs in qaddy-devtools, unless the app itself needs it at runtime.
- **Cross-repo work.** Work that spans both repositories is one project but gets separate commits in each, and each commit message names the related commit or document in the other repository.
- **Git.** Commit or push only when asked.
