# Onboarding Spec

## Purpose

Onboarding should introduce Roomly as a premium weather and indoor comfort app without overpromising exact indoor measurement.

## Product Positioning

Roomly helps users understand:

- Local Weather
- Indoor Estimate
- Comfort Index
- Humidity and pressure context
- How indoor comfort may feel throughout the day

## V1 Scope

Onboarding is planned but not required for the current mock UI unless explicitly prioritized.

Recommended flow:

1. Welcome to Roomly.
2. Explain Indoor Estimate and Comfort Index.
3. Choose preferred units.
4. Optional premium introduction.

## Wording Rules

Use:

- Estimate indoor comfort
- Understand your home climate
- Local Weather
- Comfort Index

Avoid:

- Measure your room temperature
- Exact indoor readings
- Sensor-grade accuracy

## UI Requirements

- SwiftUI only.
- Dark premium visual language.
- Minimal pages with strong typography.
- Glassmorphism panels where useful.
- Standard iOS controls for unit selection.
- Skip or continue actions should be obvious.

## Architecture Notes

- Future screen folder: `Roomly/Screens/Onboarding`.
- Use a small `OnboardingViewModel` only if onboarding owns selected units or completion state.
- Persist onboarding completion only after persistence is intentionally added.
- For V1 mock mode, completion can be local state.

## Acceptance Criteria

- Onboarding makes no exact measurement claims.
- Onboarding can be skipped.
- Unit selection is clearly marked as preference, not a backend setting.
- No networking, accounts, or analytics are added by default.
