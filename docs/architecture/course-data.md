# Course Data

**Status:** Implemented (November 2026) — the seams are in; no provider is connected.

**Scope:** everything Qaddy knows about a golf course from outside itself: the course and its holes, hole pictures and flyovers, GPS distances to the green and the forecast.

# The rule

**Qaddy does not invent golf data.** It does not ship a course database, guess a hole's length or make up a forecast. Course data comes from outside, GolfCore is being evaluated as the provider, and every course-related screen must be able to consume real data without being rewritten. Where data is not available the UI draws a placeholder of the same size and says "–" or says why; it never fills the gap.

# Shape

```
lib/features/courses/
  models/   course.dart        Course, CourseTee, CourseLocation, CourseSummary, CourseQuery
            course_hole.dart   CourseHole: number, par, stroke index, metres
            hole_guide.dart    HoleGuide: HoleDistances, Forecast, HoleMedia; HoleRef
  data/     course_data_source.dart   the four interfaces and their Unavailable* defaults
            sample_course_data.dart   the Sample Clubhouse's one course (sample content)
            standard_layout.dart      par and stroke index only (see "The standard layout")
  state/    course_providers.dart     the only place a provider is chosen
  ui/       course_picker_sheet.dart  CoursePickerSheet, CourseRow (the logo slot)
```

The models are **Qaddy's own**. A provider's adapter maps its fields into them; no screen ever sees a GolfCore type.

## The four interfaces

| Interface | Answers | Default |
|---|---|---|
| `CourseCatalogue` | `search(CourseQuery)`, `course(id)`, `isConnected` | `UnavailableCourseCatalogue`: finds nothing, `isConnected` false |
| `HoleMediaSource` | a hole's aerial picture and flyover film | `UnavailableHoleMedia`: none |
| `HoleDistanceSource` | live GPS distances to the green (a stream) | `UnavailableHoleDistances`: emits nothing |
| `WeatherSource` | the forecast for a course at a time | `UnavailableWeather`: none |

An integration implements what it can and leaves the rest on the defaults. They are separate because providers differ: a course database may have holes but no GPS, and weather will likely be a different service altogether.

## Providers

`state/course_providers.dart` holds `courseCatalogueProvider`, `holeMediaSourceProvider`, `holeDistanceSourceProvider` and `weatherSourceProvider`. **Connecting GolfCore means changing those providers (or overriding them in `main`); nothing else.**

On top of them:

- `selectedCourseProvider`: the course the golfer picked for the next round.
- `nextRoundCourseProvider`: the picked course, else the sample course (Sample Clubhouse on), else the standard layout at the golfer's home course.
- `holeGuideProvider(HoleRef)`: a stream of `HoleGuide` (forecast, pictures, then GPS distances as they arrive). A source that throws counts as "not known"; the scorecard never breaks because a provider is down.

# Where it shows up

- **Create round** (Rounds): a *Course* row shows the course, with *Change* opening the picker. The picker searches the catalogue and handles every state honestly: searching, results, no match, an unreachable provider (with *Try again*) and a catalogue that is not connected yet (it says so). *Use the standard layout* is always there.
- **Starting a round** copies the course's name, id and **holes** into the `Round`. A round carries its own holes, and they are saved with it (rounds codec: `courseId` and `holes`), so a played round reads right whatever the catalogue says later, or offline. Rounds saved before this are read as before (`layout`).
- **Live scorecard**: `HoleView` takes a `HoleGuide`. Back, middle and front are GPS when there is a fix; the middle shows the hole's length from the course data otherwise. Wind and the weather tile come from the forecast; the aerial from `HoleMedia.aerialUrl`. Missing parts are dashes at the same size. The flyover pill stays "Flyover soon" until a flyover player exists.
- **Course logos and photos**: `CourseRow` has a 44-pixel logo slot and `Course` has `logoUrl` and `photoUrl`; they show the placeholder until a URL arrives, and also if it fails to load (`QaddyMediaPlaceholder` always draws its placeholder underneath).

# The standard layout

Stableford needs par and stroke index for every hole, so a round with no course chosen is scored on a **standard par-72 layout**. It is a scoring convenience, not a course: no name, no distances, no pictures, marked `CourseOrigin.generic`, and the UI says "Standard layout". Rounds on it store `courseId: null`.

# The Sample Clubhouse

The sample course (Richmond, with a made-up scorecard and a 21° sunny forecast) is the **only hard-coded course** and is served through the same interfaces a real provider will use, so the app is exercised as it will run with GolfCore. It is sample content, labelled Sample, and exists only while the Sample Clubhouse is on (`sampleOnProvider`).

# Integrating GolfCore (when it begins)

1. Write `GolfCoreCatalogue implements CourseCatalogue` (and the other sources the API covers) under `features/courses/data/`, mapping GolfCore's course, tee, hole, location and media fields into `Course`, `CourseTee`, `CourseHole`, `CourseLocation` and `HoleMedia`. Keep the HTTP client and the API key behind `core/services` and `core/config`.
2. Cache what is fetched on the device (courses a golfer has played or favourited), so scoring works offline. A cache is a `CourseCatalogue` wrapping another.
3. Change the four source providers. Leave the screens alone.
4. Decide, with the real API in hand: which tee a golfer plays (`CourseTee` is ready; there is no tee picker yet), whether a round stores a tee id, and licensing for pictures and film.

# Not done, on purpose

- No tee picker (the default tee is used).
- No flyover player and no map (`HoleMedia.flyoverUrl` is there for them).
- No GPS permission flow or position stream (`HoleDistanceSource` is the seam).
- No course favourites or "courses near me" screen (`CourseQuery` has the position).
- Trips and Groups still store course *names* typed by the golfer; connecting them to course ids is a follow-up once the catalogue is real.
