# Flutter Style Guide

## Folder Structure

Feature-first architecture.

Shared widgets remain outside features.

---

## Widget Rules

Maximum widget length:

200 lines

Extract reusable widgets.

Keep build methods simple.

---

## Naming

PascalCase for classes.

camelCase for methods.

snake_case for filenames.

---

## Constants

Never hardcode:

Colours

Spacing

Radius

Durations

Typography

Use the design tokens.

---

## State Management

Riverpod only.

No Provider.

No GetX.

No Bloc.

---

## Navigation

GoRouter only.

No Navigator.push unless absolutely necessary.

---

## Architecture

UI

↓

ViewModel

↓

Repository

↓

Supabase

↓

Database