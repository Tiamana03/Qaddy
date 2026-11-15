# Qaddy — guide for coding agents

`CLAUDE.md` in this folder is the single engineering source of truth for every coding agent working in this repository, Codex included. Read it in full before any work and follow it exactly. It covers:

- the two-repository ownership model (Qaddy here, qaddy-devtools at `C:\Developer\qaddy-devtools`)
- the Flutter workflow and the rules: docs change only with the user's approval, no developer tooling here, commit or push only when asked

`CLAUDE.md` pulls in the app's engineering guide, `docs/CLAUDE.md`, with an `@docs/CLAUDE.md` line. If your tool does not follow that import, read `docs/CLAUDE.md` too; its reading order refers to files in `docs/`.

This file deliberately holds nothing else, so the rules live in one place. Change them in `CLAUDE.md`, never here.
