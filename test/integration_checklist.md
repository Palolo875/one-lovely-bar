# Integration / Perf / Accessibility Checklist (no-run)

## Integration flows

- Navigation shell loads with 4 tabs
  - Home -> Itinerary -> Planning -> Profile
- Onboarding gating
  - First launch shows onboarding
  - Skip sets onboarding flag and goes to shell
- Place search
  - Open search from Home / Itinerary
  - Select suggestion returns coords
- Itinerary
  - Compute route
  - See alerts + weather timeline
  - Save trip -> appears in history
  - Start guidance
- Guidance
  - Map loads, route line appears
  - Follow on/off works
  - TTS start/stop
  - Shelter action list -> start navigation to shelter

## Performance

- Home map
  - pan/zoom does not stutter with layers toggled
- Radar layer
  - no repeated add/remove loops
- Guidance
  - GPS stream at 10m filter does not cause jank

## Accessibility

- TalkBack/VoiceOver
  - Profile settings list tiles read correctly
  - Bottom sheet handle reachable
  - Buttons in guidance are labeled

## Privacy / RGPD checks

- Verify no analytics calls without opt-in
- Verify location is only requested when used

