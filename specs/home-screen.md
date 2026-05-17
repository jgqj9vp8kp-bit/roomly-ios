# Home Screen Spec

## Purpose

The Home screen is Roomly's primary dashboard. It should immediately communicate a premium indoor comfort estimate and the surrounding local weather context.

## Product Requirements

- Show the Roomly brand.
- Show the current location or home label.
- Show freshness text for mock data.
- Feature `Indoor Estimate` as the hero value.
- Show `Comfort Index` as a prominent score.
- Show `Local Weather` context through outdoor conditions.
- Include these metrics:
  - Indoor Estimate
  - Outdoor Temperature
  - Comfort Index
  - Humidity
  - Wind
  - Pressure
- Provide a premium entry point that opens the Paywall screen.

## Wording Rules

Use:

- Indoor Estimate
- Comfort Index
- Local Weather

Do not use:

- Exact indoor temperature
- Measured room temperature
- Real-time room reading

## UI Requirements

- Dark premium background.
- Glassmorphism hero card.
- Reusable metric cards.
- SF Symbols for each metric.
- Clear visual hierarchy: brand, hero estimate, comfort score, metric grid.
- No visible onboarding copy on this screen.
- No backend loading state in V1.

## Architecture Notes

- The screen lives in `Roomly/Screens/Home`.
- Shared metric cards should live in `Roomly/Components` or `Roomly/DesignSystem` when reused.
- Mock values should come from `Roomly/Models`.
- Add `HomeViewModel` only when refresh, loading, errors, or service injection are introduced.

## Acceptance Criteria

- Home screen builds with SwiftUI only.
- All required metric names appear exactly or safely.
- Paywall can be opened from Home.
- UI is readable in dark mode.
- No UIKit is introduced.
