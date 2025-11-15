# Repository Guidelines

This document is a short contributor and agent guide for this Flutter restaurant ordering app.

## Project Structure & Modules

- `lib/` – main Dart source (screens, providers, models, services, routing, theming).
- `test/` – unit and widget tests.
- `assets/` – images, icons, and static data.
- `web/`, `android/`, `ios/`, `linux/`, `macos/`, `windows/` – platform-specific runners and configs.

When adding new features, prefer placing:
- UI in `lib/screens/`
- State in `lib/providers/`
- Data models in `lib/models/`
- API calls in `lib/services/`

## Build, Test, and Development

- `flutter pub get` – install/update dependencies.
- `flutter run -d chrome` – run the web app for development.
- `flutter test` – run all unit and widget tests.

Run tests before pushing changes that affect business logic or networking.

## Coding Style & Naming

- Follow Dart style and `analysis_options.yaml` (2‑space indentation, trailing commas where idiomatic).
- Use `UpperCamelCase` for classes, `lowerCamelCase` for members and variables.
- Keep widgets small and composable; extract helpers into private methods (`_buildXyz`) when reused.
- Place navigation helpers and routes in `lib/utils/` and `lib/utils/routes.dart`.

## Testing Guidelines

- Add tests under `test/` mirroring the `lib/` path where possible.
- Name tests descriptively, e.g. `order_provider_test.dart`, `checkout_screen_test.dart`.
- Prefer testing providers and services around API and state transitions.

## Commit & Pull Request Practices

- Use clear, imperative commit messages (e.g. `Add order tracking timeline`).
- For pull requests, include:
  - A short summary of the change and motivation.
  - Any relevant screenshots for UI updates.
  - Notes on testing performed (`flutter test`, manual flows exercised).

