# Phase 1 — Scaffold

## Status: in progress

## Scope

- Flutter project initialized with Android + iOS only.
- Feature-first folder skeleton in `lib/`.
- `core/` (capabilities, settings model, logging).
- `app/` (MaterialApp, router, theme, dependency injection wiring).
- `features/shell/` (main shell with bottom navigation: Chat, Store, Models, Settings).
- Placeholder screens for the four main features.
- `pubspec.yaml` with all dependencies declared for the full project (Drift, Riverpod, go_router, dio, file_picker, permission_handler, workmanager, flutter_tts, speech_to_text, etc.) but only the routing/state libs are wired in this phase.
- `.gitignore` for Flutter, Android, iOS, generated code, downloaded model weights.
- `LICENSE` (MIT).
- `README.md` with project overview, features, roadmap, architecture, build instructions.
- `docs/plan.md` as the authoritative source of truth for scope and design.
- GitHub Actions CI workflow running `flutter analyze` + `flutter test` on every push and PR.

## What is NOT in this phase

- No real database (Drift schema is declared as a dependency but no tables yet).
- No providers (Ollama / HF / Custom URL / API adapters come in Phase 2).
- No inference engine (FFI to llama.cpp is Phase 3).
- No real chat, no slash parser, no model pill — those screens show informative placeholders.

## Verification

After Phase 1, the project must:
- `flutter pub get` resolves cleanly.
- `flutter analyze` returns zero issues.
- `flutter test` runs and passes.
- `flutter run -d android` (or iOS) launches the app, shows the bottom navigation, and navigates between the four tabs without errors.

## Next phase

Phase 2: Providers + Store. Adds provider entities, Drift schema for `providers` and `models`, settings repository (real, with persistence), provider configuration UI in Settings, store list with filters, download with progress.
