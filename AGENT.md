# AGENT.md

## App Overview

This project is a Flutter Pomodoro timer app for Android. The product direction is a cozy, pastel-focused timer experience with multiple selectable visual themes.

The app should feel calm, soft, and pleasant to use during focused work sessions. The design avoids harsh productivity aesthetics and instead uses warm cards, rounded controls, gentle gradients, pastel palettes, and expressive typography.

## Current Product Decisions

- Framework: Flutter
- Primary target: Android
- Design direction: cozy pastel
- Theme strategy: keep multiple full-app themes instead of choosing only one
- Theme selection location: configuration screen
- Theme selector layout: vertical list of larger theme cards
- Home screen should focus on the timer experience, not theme selection
- Configuration screen should contain app customization options

## Current Themes

The app currently keeps four full visual themes:

1. Moonlit Pastel
   - Mood: calm evening focus
   - Colors: dusky lavender, mauve, moon yellow, warm cream
   - Visual feeling: quiet night, soft-focus, moon/stars

2. Cottage Calm
   - Mood: tea, herbs, slow work
   - Colors: sage, blush, honey, cream
   - Visual feeling: cozy cottage desk, plants, soft daylight

3. Peach Cafe
   - Mood: warm cafe study session
   - Colors: peach, vanilla, cocoa, rose cream
   - Visual feeling: handmade, warm table glow, coffee shop

4. Cloud Nap
   - Mood: airy and dreamy
   - Colors: powder blue, lavender, pale pink, cream
   - Visual feeling: soft clouds, gentle afternoon focus

## Current App Structure

- Home screen:
  - Shows selected theme styling
  - Displays app header
  - Displays static timer prototype
  - Displays palette/type preview
  - Has a configuration button

- Configuration screen:
  - Shows selected theme styling
  - Contains App Theme
  - Uses vertical theme cards
  - Selecting a theme updates the full app theme immediately

## Implementation Notes

- Theme state currently lives in the main/home screen state.
- Theme changes are passed to the configuration screen through callbacks.
- The timer is still a visual prototype and does not yet implement real countdown behavior.
- Existing tests verify that the configuration screen can switch from the default theme to Peach Cafe.

## Future Plan

1. Implement real Pomodoro timer behavior:
   - Focus session
   - Short break
   - Long break
   - Start, pause, reset
   - Session transitions

2. Add persistent settings:
   - Save selected theme
   - Save timer durations
   - Save notification preferences

3. Add Android notifications:
   - Notify when a session ends
   - Optional sound/vibration

4. Improve configuration screen:
   - Timer duration settings
   - Notification settings
   - Theme preview refinements

5. Polish UX:
   - Better timer animations
   - Haptic feedback
   - Accessibility labels
   - Responsive spacing for small phones

6. Prepare app identity:
   - App icon
   - Splash screen
   - App name decision

## Project Decision Log Rule

This file must be updated whenever a meaningful product, design, architecture, or implementation decision is made.

Examples of decisions that should update this file:

- Adding or removing a theme
- Choosing the final default theme
- Changing navigation structure
- Changing state management approach
- Adding persistence
- Adding notification behavior
- Changing timer session rules
- Renaming the app
- Changing target platforms

Keep this file current so future agents and contributors understand the app direction and decisions already made.
