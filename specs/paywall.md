# Paywall Spec

## Purpose

The Paywall screen presents Roomly Premium as a richer comfort and weather experience. V1 is a mock paywall only.

## Product Requirements

- Present Roomly Premium clearly.
- Explain premium benefits in concise, trustworthy language.
- Include a primary call to action.
- Include restore purchases as a placeholder action.
- Make it clear in implementation that no real purchase flow exists yet.

## Premium Benefit Themes

Good benefit language:

- Room-by-room comfort estimates
- Indoor comfort trends
- Humidity and pressure alerts
- Premium dark widgets
- Extended Local Weather outlooks

Avoid benefit language:

- Exact room temperature measurement
- Guaranteed comfort prediction
- Medical or safety claims

## UI Requirements

- Full dark premium presentation.
- Glassmorphism feature list.
- Strong crown or premium visual cue using SF Symbols.
- Large, clear price area if mock pricing is shown.
- Close button must be available.
- Use a sheet from Home or Settings for V1.

## Architecture Notes

- Screen lives in `Roomly/Screens/Paywall`.
- Do not add StoreKit until real purchase requirements exist.
- Keep premium features in mock data or a simple local model.
- Future payment integration should be isolated behind a service protocol.

## Acceptance Criteria

- Paywall opens from Home and Settings.
- Close action works.
- No StoreKit dependency is added in V1.
- No exact indoor measurement claims appear.
- UI remains SwiftUI-only.
