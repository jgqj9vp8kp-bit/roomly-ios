# Roomly Architecture

Roomly uses a lightweight MVVM-oriented SwiftUI architecture. The goal is a clean path from mock UI to real data without burying a small app under unnecessary abstractions.

## Current Module Layout

```text
Roomly/
  Components/       Reusable cross-screen SwiftUI components
  DesignSystem/     Theme, gradients, glass cards, shared visual primitives
  Models/           Domain models and mock data
  Resources/        App-owned static resources
  Screens/          Feature screens and root navigation
  Services/         Future data providers and integrations
  ViewModels/       Feature presentation state when needed
```

Planning and AI guidance live outside the app target:

```text
docs/               Architecture and product rules
specs/              Feature specifications
tasks/              Implementation task plans
```

## MVVM Guidance

Use MVVM where it adds clarity:

- A screen has derived presentation state.
- A screen coordinates multiple actions.
- A screen will later depend on services.
- The logic is easier to test outside SwiftUI layout code.

Do not create a view model for a purely static layout with mock values. In those cases, keep data in `Models` and composition in `Screens`.

## Suggested Dependency Flow

```text
Screen -> ViewModel -> Service Protocol -> Service Implementation
       -> Components
       -> Models
       -> DesignSystem
```

Views should not call networking or persistence directly. Services should not import SwiftUI unless there is a strong reason.

## Data Strategy

V1 uses mock data only. Keep mock data clear and centralized so future real services can replace it behind protocols.

Recommended path:

1. Keep `MockWeatherData` for prototype data.
2. Introduce `WeatherProviding` in `Services` when live data is requested.
3. Add `HomeViewModel` only when Home needs loading, error, refresh, or source selection state.
4. Keep product wording safe: `Indoor Estimate`, `Comfort Index`, and `Local Weather`.

## Screen Responsibilities

Screens should:

- Compose the feature layout.
- Own simple local UI state.
- Present sheets and navigation destinations.
- Delegate reusable visual elements to `Components` or `DesignSystem`.

Screens should not:

- Contain backend calls.
- Contain long mock data arrays.
- Duplicate shared metric card styles.
- Make exact indoor measurement claims.

## Component Responsibilities

Components should be reusable, focused, and visually consistent. Good candidates:

- Glass cards
- Metric cards
- Forecast rows
- Premium buttons
- Section headers
- Empty states

If a component is only used once and extraction makes the screen harder to read, keep it local as a private subview.

## Service Rules

No services are required for V1 mock UI. When services are introduced:

- Define a protocol first.
- Provide a mock implementation for previews and tests.
- Keep service models separate from external API response shapes if the API is unstable.
- Inject services into view models instead of reading global singletons.

## Testing Guidance

For V1:

- Build the app after structural changes.
- Add unit tests when view models or services contain logic.
- Use previews for screen and component validation.

When live data begins:

- Test mapping from service responses to domain models.
- Test safe fallback wording and unavailable data states.
- Test view model loading and error states.

## Overengineering Guardrails

- Do not add a dependency injection container for V1.
- Do not add a router object until navigation grows beyond tabs and sheets.
- Do not introduce Combine pipelines unless the data flow demands it.
- Do not split every visual element into a separate file automatically.
- Prefer one clear file over five tiny files with no independent purpose.
