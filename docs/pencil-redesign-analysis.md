# Pencil Redesign Analysis

## Source Review

The Pencil file at `../roomly.pen` contains placed screenshot references rather than editable design-system layers. The attached screenshots show a weather app direction built around a bright iOS canvas, vivid blue weather panels, compact rounded metric cards, strong pill CTAs, simple SF Symbol-style icons, and a bottom-tab/settings/paywall flow.

## Visual Style Found

- Palette: white and off-white backgrounds, saturated cobalt/sky-blue gradients, small warm yellow/orange weather accents, soft gray utility tiles, and dark near-black text.
- Typography: rounded, bold iOS-style display text for temperatures and headlines; compact semibold labels for cards and rows.
- Spacing: tight mobile spacing with 16-20 pt page margins, 10-14 pt gaps inside grids, and dense but readable grouped cards.
- Card style: large gradient weather panels, light gray rounded metric tiles, white grouped settings surfaces, and subtle elevation rather than heavy glass.
- Button style: full-width saturated blue rounded CTA buttons, small pill secondary buttons, and compact circular icon controls.
- Navigation style: minimal top chrome, small icon actions, and standard iOS bottom tab navigation.
- Visual hierarchy: the weather/temperature card is the first major signal, followed by local context, then metric tiles.
- Recurring motifs: blue forecast panels with weather icons, two-column metric grids, rounded segmented plan selectors, and small badge-like affordances.

## Reuse

- Reuse the bright premium weather palette and strong blue panels.
- Reuse compact icon-led metric cards for humidity, feels like, wind, and pressure.
- Reuse full-width blue CTA treatment on onboarding and paywall.
- Reuse two-plan paywall selection with a highlighted yearly plan.
- Reuse settings as simple grouped rows with SF Symbols and restrained disclosure affordances.

## Do Not Copy Directly

- Do not copy the old app's measurement-heavy wording or thermometer claims.
- Do not copy crowded ad placements, permission dialogs, or screenshots that imply a real sensor/API flow.
- Do not copy the older low-fidelity icon art directly; use polished SF Symbols and Roomly-specific hierarchy.
- Do not make the UI feel like a clone of the reference app; Roomly should feel more premium, calmer, and more trustworthy.

## Roomly Adaptation

Roomly should use the reference style as a bright premium weather foundation while changing the product language to careful comfort wording. The hero should combine `Indoor Estimate` with a large `Comfort Index` gauge, then support it with `Local Weather` and condition metrics. The UI should feel App Store-ready: precise spacing, soft elevation, rounded iOS controls, clear plan selection, and no claims of exact room measurement.

## Future Screen Rules

- Use `Indoor Estimate`, `Comfort Index`, `Local Weather`, and `Estimated Room Comfort` as the core vocabulary.
- Use light canvas backgrounds with cobalt/sky-blue gradient feature panels.
- Keep metric cards compact, icon-led, and grouped in two-column grids.
- Use 20 pt horizontal page padding and 12-22 pt section spacing unless a screen needs tighter controls.
- Keep primary CTAs full-width, blue, rounded, and visually dominant.
- Prefer SF Symbols over custom weather art unless a real illustration system is introduced.
- Keep card corners in the 16-28 pt range; avoid excessive glass blur on the bright UI.
- Use mock/prototype wording for purchases, data, and settings until real services are added.
- Keep SwiftUI screens composed from reusable components in `Roomly/Components` and visual tokens in `Roomly/DesignSystem`.
