# Engineering Principles

## Architecture

Feature First Architecture

Shared Core

No business logic in widgets

Services handle external systems

Repositories own data

UI is declarative

---

## Theme

Never hardcode colours

Never hardcode spacing

Always use ThemeExtensions

No widget-specific colours

---

## Widgets

Single responsibility

Reusable first

Composition over inheritance

Small widgets

Stateless where possible

---

## State Management

Riverpod only

No Provider

No setState for app state

StateNotifier where appropriate

---

## Routing

GoRouter only

Named routes

Centralised route definitions

---

## Naming

PascalCase classes

camelCase methods

snake_case files

Meaningful names

---

## Testing

Unit tests

Widget tests

Golden tests

Integration tests

Critical business logic tested

---

## Performance

Avoid unnecessary rebuilds

const constructors

Lazy loading

Pagination

Image caching

---

## Error Handling

No silent failures

Meaningful exceptions

User-friendly messages

Logging

Recovery where possible

---

## AI Rules

AI assists.

Documentation decides.

Developers approve.

Never merge generated code blindly.