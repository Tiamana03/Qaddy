# Environment config

Copy the relevant `.example` file (e.g. `dev.json.example` → `dev.json`) and
fill in real values once they exist. The real files are gitignored — never
commit actual Supabase keys or DSNs.

Run/build with:

```
flutter run --dart-define-from-file=lib/core/config/env/dev.json
```

Until a real Supabase project exists (see the Release One roadmap, M0),
`SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` can stay empty —
`AppConfig.isBackendConfigured` is false in that case and the app boots
without attempting a connection.
is false in that case and the app boots without attempting a connection.
