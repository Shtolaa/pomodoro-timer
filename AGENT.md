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
- Timer sessions should auto-start after each session completes
- Timer should continue when the app is closed
- Notifications are required
- Presets are timer-related only and separate from app themes
- Presets should use cozy card UI consistent with the app themes
- Presets should use predefined app icons
- Preset card colors must be selected from curated pastel colors only
- Statistics should be included in the app
- Statistics should count only completed focus sessions
- Deleting a preset should keep historical statistics by default
- The app should provide an explicit option to delete a deleted preset's historical statistics
- The Android home-screen widget should include start/pause control

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
  - Displays real in-memory timer countdown
  - Displays palette/type preview
  - Has a configuration button

- Configuration screen:
  - Shows selected theme styling
  - Contains App Theme
  - Uses vertical theme cards
  - Selecting a theme updates the full app theme immediately

## Implementation Notes

- The codebase follows a feature-first clean architecture structure under `lib/features`, with app bootstrap code under `lib/app` and reusable UI helpers under `lib/core`.
- Timer business logic lives in `lib/features/timer/domain` and should remain pure Dart with no Flutter UI dependency.
- Timer presentation lives in `lib/features/timer/presentation`.
- Preset domain models live in `lib/features/presets/domain` and should remain pure Dart with no Flutter UI dependency.
- Preset icon and card color choices are represented as curated enum keys in the domain; Flutter icon/color mapping belongs in presentation.
- Preset IDs are positive integers for local-only storage; new preset IDs should be calculated as max existing preset ID plus one, including soft-deleted presets, and IDs should never be reused.
- Presets are persisted locally with `shared_preferences` as JSON, including soft-deleted presets.
- The only seeded in-memory preset is Standard Pomodoro: 25-minute focus, 5-minute short break, 30-minute long break, and 4 focus sessions before long break.
- Selecting a preset resets the active timer immediately to that preset's focus session.
- Creating a preset appends it to in-memory state, makes it active immediately, and resets the timer to the new focus duration.
- Editing the active preset preserves its ID and creation timestamp, updates its configuration, and resets the timer to the edited focus duration.
- Deleting a preset soft-deletes it with `deletedAt`; deleted presets are hidden from the active preset selector but remain in memory for future persistence/statistics work.
- If the active preset is deleted, the app selects another non-deleted preset and resets the timer. Delete is disabled when only one non-deleted preset remains.
- App theme models and theme definitions currently live in `lib/features/app_theme/domain` as a pragmatic UI-adjacent domain model because themes include Flutter `Color`, `IconData`, and `TextStyle` factories.
- App theme selection UI lives in `lib/features/app_theme/presentation`.
- Do not add a dependency injection or state management package until richer shared state makes it necessary.
- Theme state currently lives in the main/home screen state and the selected theme is persisted locally by stable theme name.
- Theme changes are passed to the configuration screen through callbacks.
- Timer state currently lives in the main/home screen state and is persisted locally for app reopen in the local-only sense.
- Timer countdown and session transitions are handled by a pure Dart timer engine in `lib/timer_engine.dart`.
- The timer engine is timestamp-based in memory and auto-starts the next session after completion.
- The timer currently uses hardcoded local durations: 25-minute focus, 5-minute short break, 15-minute long break, and a long break after 4 completed focus sessions.
- Timer configuration validates that focus, short break, and long break durations are greater than `Duration.zero` to prevent non-advancing auto-start loops.
- Timer display uses ceil-style remaining seconds so a newly started 25-minute timer remains visually at `25:00` during the first partial second.
- Existing tests verify that the configuration screen can switch from the default theme to Peach Cafe.
- Timer engine tests verify countdown controls, automatic session transitions, duration validation, and display formatting.
- Background timer restoration reconstructs running timer state from persisted start/end timestamps and advances through auto-started sessions that elapsed while the app was closed.
- Paused timer restore preserves the saved paused remaining time without elapsed-time catch-up; idle or invalid timer data falls back safely to an idle focus timer.
- Local persistence currently stores active preset ID, timer session type, status, nullable start/end timestamps, paused remaining seconds, completed focus sessions in the current cycle, and whether notifications are enabled.
- Local timer restore performs elapsed-time catch-up for saved running timers using the active preset's current timer configuration.
- Invalid or corrupt persisted theme, preset, active preset, or timer data falls back safely to the default theme, Standard Pomodoro preset, and an idle focus timer.
- Android local notifications are implemented with `flutter_local_notifications`, inexact scheduled notifications for the next running session's end time, and immediate local notifications for session transitions detected while the app is open.
- Notifications are off by default; enabling them from the configuration screen requests Android 13+ notification permission and persists the user's setting locally.
- If notifications are disabled, pending timer notifications are canceled and no new timer notifications are scheduled.
- Timer notifications are scheduled when a timer starts or resumes, canceled when a timer pauses, resets, or the active preset changes, and rescheduled when a restored running timer is loaded or an in-app auto-start transition advances to a new session. In-app auto-start transitions also show an immediate transition notification using a separate notification ID so the next scheduled notification does not replace it.
- Notification text names the completed session and the auto-started next session.
- Notification v1 intentionally uses Android inexact scheduling, so Android battery optimization or Doze may delay delivery. Exact end-time alarms are deferred to notification v2, which should evaluate exact alarm capability handling and `SCHEDULE_EXACT_ALARM` permission UX/policy requirements.
- Local persistence does not include statistics or Android widgets yet; those remain separate deferred roadmap steps.
- Auto-start behavior must be handled by the timer engine because it affects app reopen logic, notification scheduling, and widget state.
- Widget and notifications should read/update the same persisted timer state as the app.
- Statistics should store preset snapshots so deleted presets can still appear in historical data.

## Functional Roadmap

1. Core timer:
   - Focus session
   - Short break
   - Long break
   - Start, pause, resume, reset
   - Auto-start next session after completion
   - Long break after the configured number of completed focus sessions
   - Only completed focus sessions count toward statistics

2. Timer presets:
   - User-created presets
   - Presets affect timer behavior only, not the app theme
   - Preset name
   - Focus duration
   - Short break duration
   - Long break duration
   - Sessions before long break
   - Icon from predefined app icon set
   - Card color from curated pastel palette
   - Create, edit, delete, and select active preset
   - Display presets as cozy cards

3. Persistence:
    - Save selected theme
    - Save presets
    - Save active preset
    - Save active timer state
    - Persist timer state using timestamps so the timer can continue when the app is closed

4. Background timer:
   - Timer continues when the app is closed
   - Store active preset ID
   - Store current session type
   - Store timer status
   - Store session start timestamp
   - Store session target end timestamp
   - Store paused remaining duration
   - Store completed focus sessions in current cycle
   - Recalculate timer state on app reopen
   - If sessions ended while the app was closed, auto-start subsequent sessions based on saved timestamps

5. Notifications:
    - Notify when focus session ends
    - Notify when short break ends
    - Notify when long break ends
    - Because sessions auto-start, notifications should explain which session ended and which one started
    - Add Android notification permission flow
    - Add notification enable/disable setting
    - Done: v1 uses inexact scheduled local notifications, Android 13+ notification permission, and a persisted enable/disable setting
    - Deferred: exact end-time alarms should be evaluated for notification v2
    - Optional sound and vibration can be added later

6. Configuration screen:
   - Keep app theme selector
   - Add preset management
   - Notification settings
   - Curated pastel color selector for preset cards
   - Predefined icon selector for presets

7. Statistics:
   - Count only completed focus sessions
   - Sessions completed
   - Total focus hours
   - Hours per preset
   - Sessions per preset
   - If a preset is deleted, historical statistics remain by default
   - Statistics should retain preset name, color, and icon snapshots
   - Deleting historical statistics should be a separate explicit action with confirmation

8. Android home-screen widget:
   - Show current timer
   - Show current session type
   - Show active preset name
   - Include start/pause control
   - Use shared persisted timer state
   - Start/pause from widget should update app timer state and scheduled notifications

9. Polish UX:
   - Smooth circular progress animation
   - Cozy transition between sessions
   - Theme-specific visual details
   - Preset card animations
   - Haptic feedback
   - Accessibility labels
   - Small-screen layout polish

10. App identity and release prep:
   - App icon
   - Splash screen
   - App name decision
   - Android release build
   - Privacy note if data remains local-only

## Preset UX Decisions

- Presets should be shown as cards.
- Presets should visually follow the same cozy/pastel design quality as app themes.
- Users should choose a preset icon from predefined options.
- Users should choose a preset card color from curated pastel options only.
- Do not allow arbitrary custom colors for preset cards unless this decision is revisited.
- Suggested preset icon options:
  - Book / studying
  - Meditation / self-care
  - Coffee / cafe work
  - Laptop / deep work
  - Dumbbell / exercise
  - Music / practice
  - Palette / creative work
  - Moon / rest

## Statistics Decisions

- Statistics should be included in the app.
- Count only completed focus sessions.
- Do not count short breaks or long breaks in focus statistics.
- Track sessions completed.
- Track total focus hours.
- Track hours per preset.
- Track sessions per preset.
- Deleted presets should keep historical statistics by default.
- Users should be able to explicitly delete historical statistics for a deleted preset.
- Statistics records should keep preset snapshots so historical data remains understandable if a preset changes or is deleted.

## Suggested Data Models

```text
TimerPreset
- id
- name
- focusDuration
- shortBreakDuration
- longBreakDuration
- sessionsBeforeLongBreak
- iconKey
- cardColorKey
- createdAt
- updatedAt
- deletedAt nullable
```

```text
ActiveTimerState
- activePresetId
- sessionType
- status
- startedAt
- endsAt
- pausedRemainingSeconds
- completedFocusSessionsInCycle
- autoStartEnabled = true
```

```text
FocusSessionRecord
- id
- presetId nullable
- presetNameSnapshot
- presetIconSnapshot
- presetColorSnapshot
- durationSeconds
- startedAt
- completedAt
```

## Recommended Build Order

1. Done: Real timer engine with auto-start
2. Done: Preset data model
3. Done: Preset cards and preset selection
4. Preset create/edit flow
5. Done: Local persistence
6. Done: Timestamp-based background timer restoration
7. Done: Notifications
8. Statistics
9. Android widget
10. UX polish

## Suggested Branch Roadmap

Timer engine review fixes are complete. Continue feature work in this order:

1. Done: `feature/timer-presets-model`
   - Add `TimerPreset`, preset icon keys, preset color keys, curated pastel colors, and validation tests.
   - Completed with pure Dart preset domain models, positive integer preset IDs, curated icon/color keys, `toTimerConfig()`, `copyWith`, next-ID helper, and validation tests.

2. Done: `feature/preset-cards-selection`
   - Add cozy preset cards and active preset selection UI.
   - Completed with one in-memory Standard Pomodoro preset, configuration-screen preset card, presentation icon/color mapping, and immediate timer reset on preset selection.

3. Done: `feature/preset-create-edit`
   - Add create/edit/delete preset flows.
   - Completed with an in-memory preset form, validated preset durations/sessions, curated enum-only icon/color selection, active-on-create behavior, active edit reset behavior, soft-delete hiding, fallback selection when deleting the active preset, and disabled delete when only one non-deleted preset remains.

4. Done: `feature/local-persistence`
   - Completed with `shared_preferences` local storage for selected app theme, all presets including soft-deleted presets, active preset ID, and active timer state for local reopen.
   - Persisted presets use JSON with enum names for icon/color keys, stable positive IDs, and soft-delete timestamps.
   - Invalid or corrupt local data falls back to Standard Pomodoro, the default theme, and an idle focus timer.
   - Background elapsed-time catch-up, notifications, statistics, and Android widgets are intentionally deferred to later roadmap branches.

5. Done: `feature/background-timer-restore`
   - Completed with domain-level timestamp restoration that catches up running timers after app close/reopen, advances through auto-started sessions while closed, preserves paused timers without catch-up, and falls back safely for invalid or stale persisted timer state.
   - Notifications, statistics, and Android widgets remain deferred to their separate roadmap branches.

6. Done: `feature/notifications`
   - Completed with Android local notifications, Android 13+ notification permission flow, a persisted enable/disable setting in configuration, inexact scheduled session-completion notifications, cancellation on pause/reset/preset change/disable, and rescheduling after running timer restore or auto-start session transitions.
   - Notification v1 intentionally avoids exact-alarm permission handling; exact end-time alarms are deferred to notification v2.

7. `feature/statistics`
   - Add completed focus session statistics, total focus hours, and preset breakdowns.

8. `feature/android-widget`
   - Add Android home-screen widget with timer display and start/pause control.

This order should be followed unless a new decision updates the roadmap.

## Review Findings

### Real Timer Engine Review

- Resolved: `PomodoroTimerConfig` validates that focus, short break, and long break durations are greater than `Duration.zero`.
- Resolved: Timer display uses ceil-style remaining seconds so the initial visible value remains `25:00` during the first partial second after starting.

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
- Changing preset behavior
- Changing statistics rules
- Changing background timer behavior
- Changing Android widget behavior
- Renaming the app
- Changing target platforms

Keep this file current so future agents and contributors understand the app direction and decisions already made.
