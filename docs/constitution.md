# Roomly Constitution

Roomly is a premium SwiftUI weather and indoor comfort app. It should feel calm, precise, and trustworthy without overstating what the product can know.

## Product Positioning

Roomly helps people understand local weather and estimate indoor comfort conditions from mock or future connected data sources. The app is premium, dark, atmospheric, and practical.

Roomly must never claim exact room temperature measurement unless a real sensor integration exists and the data source is clearly disclosed. Use these product terms consistently:

- Indoor Estimate
- Comfort Index
- Local Weather

Avoid wording such as exact room temperature, live room measurement, measured indoor temperature, or guaranteed comfort score.

## Technical Principles

- Build with Swift and SwiftUI only.
- Use MVVM for features that have meaningful presentation state or behavior.
- Keep simple static views simple; do not create view models just to pass constants around.
- Use mock data until a backend or sensor source is intentionally specified.
- Do not introduce UIKit unless a native SwiftUI approach is unavailable or clearly inferior.
- Keep modules small, named by feature or responsibility.
- Prefer reusable SwiftUI components over duplicated card, metric, and row layouts.
- Keep business wording and mock data centralized where practical.
- Avoid global mutable state unless it represents app-level state owned at the root.

## Architecture Rules

- `Roomly/Screens` contains screen-level composition.
- `Roomly/Components` contains reusable UI components used by multiple screens.
- `Roomly/DesignSystem` contains colors, gradients, typography helpers, and glassmorphism primitives.
- `Roomly/Models` contains value types and mock domain data.
- `Roomly/ViewModels` contains feature view models when local view state becomes more than basic SwiftUI state.
- `Roomly/Services` contains protocol-backed data sources when real integrations are added.
- `Roomly/Resources` contains app-owned non-asset resources that are not better represented in `Assets.xcassets`.
- `docs`, `specs`, and `tasks` define the product and implementation contract for AI-assisted development.

## Coding Rules

- Prefer `struct` value models with explicit names.
- Prefer dependency injection through initializers for feature-local dependencies.
- Prefer `@State`, `@Binding`, and `@Environment` before introducing reference objects.
- Use `@Observable` or `ObservableObject` only when a reference model is justified.
- Keep views readable by extracting repeated sections into private subviews or reusable components.
- Use SF Symbols for weather, comfort, settings, and premium affordances.
- Add previews for new screens and reusable components.
- Keep strings user-facing and product-safe.
- Keep comments rare and useful.

## UI Principles

- Dark premium weather UI is the default.
- Use glassmorphism cards with restrained blur, thin borders, and layered gradients.
- Maintain strong contrast and readable type.
- Use iOS-native navigation patterns: `TabView`, `NavigationStack`, sheets, and standard controls.
- Avoid cluttered dashboards; prioritize scanability.
- Use compact metric cards for weather values.
- Make premium entry points clear without making the product feel blocked.
- Use subtle color variety: cyan, blue, mint, indigo, and warm accents may appear, but no single hue should dominate every surface.

## AI-Assisted Development Rules

- Read this constitution before adding features.
- Read the relevant spec before editing a screen.
- Update the related spec when product behavior changes.
- Update `tasks/v1-ui.md` when implementation status changes.
- Keep changes scoped to the requested feature.
- Do not add networking, persistence, subscriptions, analytics, or authentication unless a spec explicitly asks for it.
- When uncertain, choose the simplest SwiftUI implementation that preserves future scalability.

## Non-Goals For V1

- No backend.
- No live weather API.
- No sensor integrations.
- No authentication.
- No real payments.
- No exact indoor measurement claims.
