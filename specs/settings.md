# Settings Spec

## Purpose

Settings lets users understand and adjust Roomly preferences while keeping V1 mock-only and lightweight.

## Product Requirements

- Show premium entry point.
- Show settings rows for:
  - Units
  - Home Profile
  - Notifications
  - Data Source
- Indicate that data is mock/prototype mode where appropriate.
- Provide a path to Paywall.

## V1 Behavior

Rows may be static placeholders unless a task explicitly asks for interactive settings.

Recommended placeholder wording:

- Units: Celsius, km/h, hPa
- Home Profile: Apartment, bedroom priority
- Notifications: Comfort shifts and pressure drops
- Data Source: Mock data for prototype

## UI Requirements

- Dark premium settings surface.
- Glassmorphism grouped rows.
- SF Symbols for row icons.
- Standard iOS row affordances.
- Clear but restrained premium card.

## Architecture Notes

- Screen lives in `Roomly/Screens/Settings`.
- A `SettingsViewModel` is not required until settings become editable or persisted.
- Future settings persistence should be isolated from SwiftUI views.

## Acceptance Criteria

- Settings screen builds in SwiftUI.
- Premium entry opens Paywall.
- Prototype/mock mode is disclosed.
- No backend, account, analytics, or real notification scheduling is added in V1.
