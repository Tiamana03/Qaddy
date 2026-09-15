# Qaddy Design Tokens

# Animations

Version: 2.0
Status: Active
Source: `design/ui-components/loaders/loaders-library-v1.png` (Loaders Library v1.0) provides one sourced timing range; no dedicated animation/motion asset exists beyond that — see [Note on Source](#note-on-source). All other values are Engineering Decisions.
Last Updated: September 2026

---

# Purpose

This file is the **single source of truth** for every animation duration, easing curve and motion pattern used inside the Qaddy application.

No screen or widget should set an animation `Duration` or `Curve` as a literal value. Every motion value must be reached through a Flutter theme token, so the app moves with one consistent rhythm rather than every screen picking its own timing.

---

# Note on Source

Unlike `colours.md` and `typography.md`, there is no dedicated animation/motion master asset in `design/assets/`. This is not, however, a total absence like `spacing.md`, `radius.md`, `shadows.md` and `elevation.md` faced — one real, numeric value was found.

The **Loaders Library** (`design/ui-components/loaders/loaders-library-v1.png`, 1312×1199px, read at native resolution) includes its own "Usage Guidelines" panel, which states, verbatim: **"Use consistent timing (600–1000ms)."** The same panel's "Contexts" section names six situations this applies to: Page Load, Data Fetch, File Upload, Sync, Form Submit, Map Load. Both are transcribed exactly in [Sourced from the Asset Library](#sourced-from-the-asset-library) below.

No other asset in the repository — including the animated-splash concept (`design/assets/splash/animated-splash-v1.png`, which only says "Smooth, subtle animation for a premium feel," no number) — gives a numeric duration, easing curve, or other motion value. Everything beyond the one sourced range is an Engineering Decision, documented with its reasoning in that section.

---

# Design Principles

- **Never hardcode motion.** Every `Duration` and `Curve` is reached through a named token, never a literal `Duration(milliseconds: 250)` inside feature code.
- **Fast, smooth, intentional — never flashy.** Per the Design Bible: motion should reinforce a user's action, not decorate it. If an animation calls attention to itself rather than to what it's animating, it's wrong for Qaddy.
- **Consistent timing, not uniform timing.** Different kinds of motion (a button press vs. a full-screen transition) legitimately need different durations — the goal is that the *same kind* of motion always takes the *same* amount of time, not that everything takes the same amount of time.
- **Loading states are the one place a real spec exists.** Where the Loaders Library gives a range, stay inside it — don't override a sourced value with a guess.

---

# Sourced from the Asset Library

## Loading Animation Timing

**Source:** Loaders Library (`design/ui-components/loaders/loaders-library-v1.png`), "Usage Guidelines" panel.

| Property | Value |
|---|---|
| Duration range | 600ms – 1000ms |
| Quoted guideline | "Use consistent timing (600-1000ms)." |

The asset specifies a *range*, not a single number, and a Flutter `Duration` constant needs one concrete value. The implementation default below uses the midpoint of the sourced range — this is a documented interpretation of the sourced range, not itself a new invented number:

| Token | Value | Flutter Token Name |
|---|---|---|
| Loading | 800ms (midpoint of the sourced 600–1000ms range) | `loading` |

Engineers may tune a specific loader's duration anywhere inside the sourced 600–1000ms range if there's a good reason to (e.g. a skeleton loader that typically resolves fast sitting nearer 600ms) — but should not go outside that range without a design decision, since 600–1000ms is the one hard constraint the asset actually gives.

## Loading Usage Contexts

Sourced directly from the same panel's "Contexts" grid — these are the situations the Loaders Library shows as needing the `loading` timing: **Page Load, Data Fetch, File Upload, Sync, Form Submit, Map Load.**

---

# Engineering Decisions

Everything below has no source asset — see [Note on Source](#note-on-source). Every value is an explicit Qaddy engineering standard.

## Duration Scale

A five-step scale for everything that isn't a loading indicator. Each step is roughly 1.5–1.6× the previous one, which is the same kind of steady, predictable progression used for the Spacing, Radius and Elevation scales — perceptually even steps rather than an arbitrary jump between values.

| Token | Duration | Reason | Usage | Flutter Token Name |
|---|---|---|---|---|
| Instant | 100ms | Fast enough to feel like direct manipulation rather than an animation. | Button press feedback, small state toggles (checkbox, switch). | `instant` |
| Fast | 150ms | Quick enough not to add perceptible delay to a frequent interaction. | Icon/scale feedback, dialog entrance. | `fast` |
| Normal | 250ms | The default for most UI motion — visible as intentional without feeling slow. | Fade in/out, slide up/down, bottom sheet entrance. | `normal` |
| Slow | 400ms | Reserved for motion covering a larger portion of the screen, where a faster duration would feel abrupt. | Large surface transitions (e.g. a bottom sheet's full expansion). | `slow` |
| Page Transition | 300ms | Sits deliberately between Normal and Slow — long enough to feel like a deliberate change of screen, short enough not to slow down navigation. This also matches the industry-standard range most mobile platforms default to for screen transitions. | Screen-to-screen navigation. | `pageTransition` |

## Easing Curves

Curves are chosen by what the motion is doing, not by animation type — an element entering the screen decelerates into place (feels like it's settling), an element leaving accelerates away (feels like it's getting out of the way), and an element that's on-screen at both ends of the animation eases both in and out.

| Token | Flutter Curve | Reason | Usage | Flutter Token Name |
|---|---|---|---|---|
| Enter | `Curves.easeOut` | Starts fast, decelerates into its final position — reads as the element "arriving." | Fade in, slide in, dialog/bottom sheet opening. | `enter` |
| Exit | `Curves.easeIn` | Starts slow, accelerates away — reads as the element "leaving," and gets out of the user's way quickly. | Fade out, slide out, dialog/bottom sheet closing. | `exit` |
| Transition | `Curves.easeInOut` | Symmetric — appropriate when both the start and end states are stable, on-screen states. | Page transitions, tab switches. | `transition` |
| Continuous | `Curves.linear` | Constant speed — appropriate only for motion that loops indefinitely, where easing would make the loop visibly jerk at the seam. | Loading spinner rotation. | `continuous` |

Reason: four curves is deliberately small. Per the Design Bible's "never flashy" rule, Qaddy does not use bounce, elastic, or overshoot curves anywhere — every curve above is a plain deceleration, acceleration, or constant-speed motion.

## Animation Type → Token Mapping

Maps each of the ten named animation types from the previous version of this file onto the duration and curve tokens above.

| Animation | Duration Token | Curve Token | Notes |
|---|---|---|---|
| Button Press | `instant` | `exit` (press) / `enter` (release) | A quick depress-and-release, not a full enter/exit. |
| Fade In | `normal` | `enter` | |
| Fade Out | `fast` | `exit` | Exits slightly faster than the matching fade-in — leaving should never feel slower than arriving. |
| Scale | `fast` | `enter` | E.g. a card or button's tap-scale feedback. |
| Slide Up | `normal` | `enter` | |
| Slide Down | `fast` | `exit` | |
| Page Transition | `pageTransition` | `transition` | |
| Bottom Sheet | `normal` (opening) / `fast` (closing) | `enter` (opening) / `exit` (closing) | Opening is more deliberate than the snappier close. |
| Dialog | `fast` | `enter` (opening) / `exit` (closing) | |
| Loading Spinner | `loading` (sourced, 800ms — see above) | `continuous` | The one animation in this table with a value from the asset library rather than an Engineering Decision. |

---

# Rules

- Never hardcode a duration or curve. If a screen seems to need a timing that isn't above, that's a design conversation, not a reason to write a literal `Duration`.
- Stay inside the Loaders Library's sourced 600–1000ms range for any loading indicator — this is the one place an actual spec exists, so don't substitute an Engineering Decision value for it.
- Animations should support the experience, not distract from it — if in doubt, the faster, subtler option is the Qaddy option.

---

# Flutter Implementation

Every token above should exist as a named field on a single `ThemeExtension` (e.g. `QaddyMotion`), consistent with the approach taken for `QaddyColours`, `QaddyTypography`, `QaddySpacing`, `QaddyRadius`, `QaddyShadows` and `QaddyElevation`. Reference motion only through that extension:

```dart
AnimatedOpacity(
  duration: Theme.of(context).extension<QaddyMotion>()!.normal,
  curve: Theme.of(context).extension<QaddyMotion>()!.enter,
  opacity: visible ? 1 : 0,
  child: child,
)
```

Never write a literal `Duration(milliseconds: 250)` or `Curves.easeOut` inline for motion that has a token above — use the token's value instead.

## Token reference

| Flutter Token Name | Value |
|---|---|
| `instant` | `Duration(milliseconds: 100)` |
| `fast` | `Duration(milliseconds: 150)` |
| `normal` | `Duration(milliseconds: 250)` |
| `slow` | `Duration(milliseconds: 400)` |
| `pageTransition` | `Duration(milliseconds: 300)` |
| `loading` | `Duration(milliseconds: 800)` — sourced range 600–1000ms |
| `enter` | `Curves.easeOut` |
| `exit` | `Curves.easeIn` |
| `transition` | `Curves.easeInOut` |
| `continuous` | `Curves.linear` |

## Example

```
Page Transition
Flutter Token: pageTransition (duration) + transition (curve)

Loading Spinner
Flutter Token: loading (duration, sourced) + continuous (curve)

Dialog
Flutter Token: fast (duration) + enter (curve)
```

---

Version 2.0
