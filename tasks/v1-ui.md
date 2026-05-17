# Roomly V1 UI Tasks

This task list guides AI-assisted implementation for the first premium mock UI milestone.

## Project Structure

- [x] Create repo-level `docs` folder.
- [x] Create repo-level `specs` folder.
- [x] Create repo-level `tasks` folder.
- [x] Create app source folders for Components, Screens, Services, Models, ViewModels, and Resources.
- [x] Move reusable UI primitives from `DesignSystem/RoomlyComponents.swift` into `Roomly/Components` when reuse grows.
- [x] Add previews for every reusable component that becomes public across screens.

## Home Screen

- [x] Build dark premium Home dashboard.
- [x] Show Indoor Estimate.
- [x] Show Outdoor Temperature.
- [x] Show Comfort Index.
- [x] Show Humidity.
- [x] Show Wind.
- [x] Show Pressure.
- [x] Add premium entry point.
- [x] Rename or add Local Weather context where product copy needs to be more explicit.
- [ ] Review small-screen spacing on iPhone SE-size simulators.

## Forecast Screen

- [x] Build Forecast screen with mock hourly and daily data.
- [x] Use dark glassmorphism styling.
- [x] Add more explicit Local Weather language.
- [ ] Consider extracting forecast cards into reusable components if reused elsewhere.

## Settings Screen

- [x] Build Settings screen.
- [x] Add mock/prototype data disclosure.
- [x] Add premium entry point.
- [ ] Decide whether settings rows remain static in V1 or open detail placeholders.

## Paywall Screen

- [x] Build mock Paywall screen.
- [x] Add premium benefit list.
- [x] Add close action.
- [x] Avoid StoreKit for V1.
- [x] Review paywall copy for exact measurement claims before any release.

## Architecture

- [x] Keep SwiftUI-only implementation.
- [x] Keep mock data only.
- [x] Use modular folders.
- [ ] Introduce view models only when behavior requires them.
- [ ] Add service protocols only when live data or persistence is requested.
- [ ] Add unit tests when logic moves into view models or services.

## Quality Gates

- [x] Run an iOS Simulator build after structural changes.
- [ ] Verify all screens render in dark mode.
- [x] Verify no UIKit imports were added.
- [x] Verify no exact indoor measurement wording appears in app UI code.
- [ ] Update specs when behavior changes.

## V1.1 Improvements

- [x] Persist onboarding completion with `@AppStorage`.
- [x] Add reset onboarding action in Settings.
- [x] Add Temperature Units control for Celsius and Fahrenheit.
- [x] Add Notifications toggle.
- [x] Add Premium status placeholder.
- [x] Improve Home comfort gauge prominence.
- [x] Keep V1.1 mock-only with no backend, live weather API, RevenueCat, or StoreKit.

## V1.1 Polish Update

- [x] Add reusable design tokens for color, spacing, corner radius, and shadows.
- [x] Improve visual hierarchy and glass card polish.
- [x] Add comfort gauge glow and progress animation.
- [x] Add card entrance animations.
- [x] Add forecast row and bar animations.
- [x] Improve onboarding copy, CTA styling, and page indicators.
- [x] Improve paywall hierarchy, trust strip, CTA emphasis, and restore placeholder.
- [x] Improve native tab bar material and active tint behavior.
