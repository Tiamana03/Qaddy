# Sprint 1.2 – Navigation Foundation

**Sprint:** 1  
**Task:** 1.2  
**Status:** Ready for Implementation

---

# Purpose

Build the complete navigation foundation for Qaddy.

This sprint establishes the application's routing infrastructure but does **not** build feature functionality.

---

# Objectives

Implement:

- GoRouter configuration
- Route constants
- Navigation shell
- Bottom Navigation
- Navigation providers (if required)
- Placeholder screens
- Route organisation

---

# In Scope

### Feature Structure

Use the existing project scaffold.

Do not create duplicate feature folders.

```text
lib/features/
    dashboard/
    rounds/
    trips/
    community/
    profile/
```

### Route Mapping

| Route | Feature Folder |
|--------|----------------|
| /home | dashboard |
| /rounds | rounds |
| /trips | trips |
| /friends | community |
| /profile | profile |

Developers must reuse the existing feature folders.

Feature folder names are implementation details and do not need to match public route names.

Developers must not rename or duplicate feature folders solely to match navigation route names unless the architecture documentation is updated first.

---

# Out of Scope

Do NOT implement:

- Dashboard UI
- Business logic
- Supabase
- Authentication
- API calls
- Feature functionality
- State management beyond navigation
- Shared widgets
- Theme changes
- Design token changes

---

# Requirements

Navigation must follow:

- docs/architecture/navigation.md
- docs/project-rules.md
- docs/engineering-principles.md

No undocumented routes may be created.

No additional tabs may be added.

---

# Acceptance Criteria

The application should:

- Launch successfully
- Use GoRouter
- Display Bottom Navigation
- Navigate between all five primary destinations
- Preserve navigation state
- Compile without warnings
- Pass flutter analyze
- Pass flutter test

---

# Deliverables

Expected outputs include:

- Router configuration
- Route constants
- Navigation shell
- Five placeholder screens
- Navigation infrastructure

---

# Do Not Build

Do not begin:

- Sprint 1.3
- Shared widgets
- Dashboard
- Cards
- Statistics
- Golf IQ
- Trips functionality
- Rounds functionality
- Friends functionality
- Profile functionality

Only placeholder pages are required.

---

# Verification

Run:

```bash
dart format .
flutter analyze
flutter test
```

All checks must pass before this sprint is considered complete.

---

# Completion Report

When implementation is complete provide:

- Summary
- Files created
- Files modified
- Engineering decisions
- Verification results
- Recommendations for Sprint 1.3

Do not continue into Sprint 1.3.