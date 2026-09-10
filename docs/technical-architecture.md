# Qaddy Technical Architecture
Version: 1.0
Status: Active
Last Updated: September 2026

---

# Purpose

This document defines the technical architecture of Qaddy.

It establishes the engineering standards, project structure and architectural principles that every contributor must follow.

The objective is to build a codebase that is scalable, maintainable and easy to understand.

---

# Architecture Philosophy

Qaddy should be:

- Modular
- Scalable
- Testable
- Maintainable
- Predictable
- Fast

Every engineering decision should favour long-term maintainability over short-term convenience.

---

# Technology Stack

## Frontend

Flutter

Reason:
- Cross-platform
- Excellent performance
- Single codebase
- Strong community
- Mature ecosystem

---

## State Management

Riverpod

Reason:
- Compile-time safety
- Predictable state
- Excellent testing support
- Scalable architecture

---

## Backend

Supabase

Responsibilities:

- Authentication
- Database
- Storage
- Realtime
- Edge Functions

---

## Analytics

Firebase Analytics

Purpose:

Understand how golfers use Qaddy while respecting user privacy.

---

## Crash Reporting

Sentry

Purpose:

Monitor application stability and resolve issues quickly.

---

# Project Structure

```text
lib/

core/
features/
shared/
services/
models/
```

## Core

Contains application-wide functionality.

Examples:

- Theme
- Routing
- Constants
- Utilities
- Configuration

---

## Features

Every major feature lives inside its own module.

Example:

features/

dashboard/

community/

golf_iq/

my_bag/

statistics/

profile/

Each feature owns:

- UI
- State
- Business logic
- Repositories

---

## Shared

Reusable widgets and utilities.

Nothing feature-specific belongs here.

---

## Services

Application services.

Examples:

- Authentication
- Notifications
- AI
- Analytics

---

## Models

Shared data models.

---

# Routing

GoRouter

Every screen should have:

- Clear route names
- Deep linking support
- Predictable navigation

---

# State Management

Business logic should remain outside widgets.

Widgets display state.

Providers manage state.

Repositories manage data.

---

# Data Flow

UI

↓

Provider

↓

Repository

↓

Supabase / API

↓

Repository

↓

Provider

↓

UI

Data should always follow this predictable direction.

---

# Error Handling

Errors should:

- Be logged
- Be user friendly
- Never expose technical information

---

# Testing

Required:

- Unit Tests
- Widget Tests

Future:

- Integration Tests

Every feature should remain testable.

---

# Performance

Priorities:

- Fast startup
- Smooth scrolling
- Efficient rebuilds
- Lazy loading
- Image optimisation

---

# Security

Never:

- Store secrets inside the application
- Commit API keys
- Trust client-side validation

Always:

- Validate server-side
- Use secure authentication
- Respect user privacy

---

# Code Standards

Code should be:

Readable.

Consistent.

Self-documenting.

Small functions are preferred over large functions.

Composition is preferred over inheritance.

---

# Engineering Principles

Build reusable components.

Avoid duplication.

Prefer clarity over cleverness.

Keep dependencies minimal.

Optimise only when necessary.

---

# Future Scalability

Qaddy should support:

- Millions of golfers
- Multiple regions
- AI services
- Offline functionality
- Wearables
- Future desktop support

Architecture decisions today should not prevent future growth.

---

# Final Principle

Write code that the next engineer enjoys reading.

The best software is software that remains understandable years after it was written.
