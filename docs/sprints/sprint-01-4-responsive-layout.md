# Sprint 1.4 — Responsive Layout & Core Utilities

## Sprint Goal

Build the responsive layout system and shared utility layer that every future Qaddy screen will use.

No feature-specific UI or business logic should be created.

---

# References

Required reading before implementation:

- docs/project-rules.md
- docs/engineering-principles.md
- docs/architecture/responsive-layout.md

### Design Tokens

- breakpoints.md
- spacing.md
- typography.md

---

# In Scope

## Responsive Layout

Create:

```
lib/core/responsive/
├── responsive_builder.dart
├── responsive_padding.dart
├── responsive_spacing.dart
├── responsive_max_width.dart
└── responsive_extensions.dart
```

All responsive helpers must follow the behaviour defined in:

- docs/architecture/responsive-layout.md

Responsive calculations must delegate to `QaddyBreakpoints`.

No responsive calculations may be duplicated.

---

## Utilities

Create:

```
lib/core/utils/
├── context_extensions.dart
├── string_extensions.dart
├── date_extensions.dart
└── formatting.dart
```

### context_extensions.dart

Provides general `BuildContext` convenience helpers that are **not related to responsive layout**.

Examples include:

- theme access
- colour access
- typography access
- scaffold access

Responsive behaviour must never exist here.

All responsive `BuildContext` extensions belong exclusively inside:

`lib/core/responsive/responsive_extensions.dart`

This separation prevents duplication of responsive calculations.

---

### string_extensions.dart

Provides reusable String helper methods.

Examples include:

- capitalize
- title case
- null-safe formatting

No business logic.

---

### date_extensions.dart

Provides reusable DateTime helper methods.

Examples include:

- friendly date formatting
- relative dates
- common date conversions

No business logic.

---

### formatting.dart

Provides reusable formatting helpers shared throughout the application.

Examples include:

- distances
- scores
- durations
- currency

No feature-specific formatting.

All formatting helpers must remain generic and reusable.

---

## Providers

Create only if implementation genuinely requires them.

```
lib/core/providers/
├── theme_provider.dart
└── settings_provider.dart
```

If no provider is required, do not create one.

---

# Do Not Build

- Dashboard functionality
- Rounds
- Trips
- Statistics
- Golf IQ
- Authentication
- Supabase
- Repositories
- API services
- Business logic
- Feature screens

---

# Requirements

- All breakpoint logic must come from `breakpoints.md`.
- No hardcoded breakpoint values.
- All spacing values must come from `spacing.md`.
- Responsive behaviour must be reusable.
- Business screens must never contain breakpoint calculations.
- Responsive calculations must delegate to `QaddyBreakpoints`.
- Responsive helper widgets must remain lightweight and reusable.
- Utility extensions must contain no business logic.

---

# Acceptance Criteria

Implementation is complete when:

- All responsive helper widgets exist and compile successfully.
- Utility extensions compile successfully.
- Breakpoint helpers use design tokens.
- No hardcoded breakpoint values exist.
- Responsive calculations are not duplicated.
- `dart format` passes.
- `flutter analyze` passes.
- `flutter test` passes.

---

# Verification

Run:

```bash
dart format --output=none --set-exit-if-changed .

flutter analyze --fatal-infos

flutter test
```

---

# Stop Conditions

Stop immediately if:

- documentation is ambiguous
- a breakpoint must be invented
- responsive behaviour is undocumented
- additional design decisions are required

Do not guess.

---

# Completion Report

Provide:

1. Summary
2. Files created
3. Files modified
4. Engineering decisions
5. Verification
6. Recommendations for Sprint 1.5

Do not begin Sprint 1.5.