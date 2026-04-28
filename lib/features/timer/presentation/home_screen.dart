import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/local_pomodoro_storage.dart';
import '../../../core/presentation/widgets/dreamy_backdrop.dart';
import '../../app_theme/domain/pomodoro_theme.dart';
import '../../app_theme/presentation/configuration_screen.dart';
import '../../presets/domain/preset_color_key.dart';
import '../../presets/domain/preset_icon_key.dart';
import '../../presets/domain/timer_preset.dart';
import '../../presets/presentation/preset_form_screen.dart';
import '../data/timer_state_codec.dart';
import '../domain/timer_engine.dart';

final _standardPomodoroPreset = TimerPreset(
  id: 1,
  name: 'Standard Pomodoro',
  focusDuration: const Duration(minutes: 25),
  shortBreakDuration: const Duration(minutes: 5),
  longBreakDuration: const Duration(minutes: 30),
  sessionsBeforeLongBreak: 4,
  iconKey: PresetIconKey.book,
  cardColorKey: PresetColorKey.peach,
  createdAt: DateTime(2026, 4, 28),
  updatedAt: DateTime(2026, 4, 28),
);

class ThemePrototypeScreen extends StatefulWidget {
  const ThemePrototypeScreen({super.key});

  @override
  State<ThemePrototypeScreen> createState() => _ThemePrototypeScreenState();
}

class _ThemePrototypeScreenState extends State<ThemePrototypeScreen>
    with WidgetsBindingObserver {
  PomodoroThemeOption selectedTheme = PomodoroThemeOption.themes.first;
  late final List<TimerPreset> presets = [_standardPomodoroPreset];
  late TimerPreset activePreset = presets.first;
  late PomodoroTimerEngine timerEngine = PomodoroTimerEngine(
    config: activePreset.toTimerConfig(),
  );
  late PomodoroTimerState timerState = timerEngine.initialState();
  LocalPomodoroStorage? localStorage;
  Timer? timerTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(loadPersistedState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    saveTimerState();
    timerTicker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      saveTimerState();
    }
  }

  Future<void> loadPersistedState() async {
    final storage = await LocalPomodoroStorage.load();
    if (!mounted) {
      localStorage = storage;
      return;
    }

    final loadedTheme = storage.loadSelectedTheme();
    final loadedPresets = storage.loadPresets();
    final usablePresets = loadedPresets == null ||
            loadedPresets.every((preset) => preset.deletedAt != null)
        ? [_standardPomodoroPreset]
        : loadedPresets;
    final activePresetId = storage.loadTimerState()?.activePresetId ??
        storage.loadActivePresetId();
    final nextActivePreset = activePresetId == null
        ? usablePresets.firstWhere((preset) => preset.deletedAt == null)
        : usablePresets.firstWhere(
            (preset) => preset.id == activePresetId && preset.deletedAt == null,
            orElse: () => usablePresets.firstWhere(
              (preset) => preset.deletedAt == null,
            ),
          );
    final nextTimerEngine = PomodoroTimerEngine(
      config: nextActivePreset.toTimerConfig(),
    );
    final loadedTimerState = restoredTimerState(
      storage.loadTimerState(),
      activePreset: nextActivePreset,
      engine: nextTimerEngine,
    );

    setState(() {
      localStorage = storage;
      if (loadedTheme != null) {
        selectedTheme = loadedTheme;
      }
      presets
        ..clear()
        ..addAll(usablePresets);
      activePreset = nextActivePreset;
      timerEngine = nextTimerEngine;
      timerState = loadedTimerState;
    });

    if (timerState.status == PomodoroTimerStatus.running) {
      startTicker();
    }
  }

  PomodoroTimerState restoredTimerState(
    PersistedTimerState? persisted, {
    required TimerPreset activePreset,
    required PomodoroTimerEngine engine,
  }) {
    if (persisted == null || persisted.activePresetId != activePreset.id) {
      return engine.initialState();
    }

    final state = persisted.state;
    final maxDuration = engine.config.durationFor(state.sessionType);
    if (state.pausedRemaining > maxDuration) {
      return engine.initialState();
    }

    if (state.status != PomodoroTimerStatus.running) {
      return state.copyWith(clearStartedAt: true, clearEndsAt: true);
    }

    final now = DateTime.now();
    return state.copyWith(
      startedAt: now,
      endsAt: now.add(state.pausedRemaining),
    );
  }

  PomodoroTimerState timerStateSnapshot([DateTime? now]) {
    final snapshotAt = now ?? DateTime.now();
    if (timerState.status != PomodoroTimerStatus.running) {
      return timerState;
    }

    final remaining = timerState.remainingAt(snapshotAt, timerEngine.config);
    return timerState.copyWith(
      startedAt: snapshotAt,
      endsAt: snapshotAt.add(remaining),
      pausedRemaining: remaining,
    );
  }

  void saveSelectedTheme() {
    final storage = localStorage;
    if (storage == null) {
      return;
    }
    unawaited(storage.saveSelectedTheme(selectedTheme));
  }

  void savePresetState() {
    final storage = localStorage;
    if (storage == null) {
      return;
    }
    unawaited(storage.savePresets(presets));
    unawaited(storage.saveActivePresetId(activePreset.id));
  }

  void saveTimerState() {
    final storage = localStorage;
    if (storage == null) {
      return;
    }
    unawaited(
      storage.saveTimerState(
        PersistedTimerState(
          activePresetId: activePreset.id,
          state: timerStateSnapshot(),
        ),
      ),
    );
  }

  void startTicker() {
    timerTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      updateTimer(
        (state, now) => timerEngine.advanceTo(state, now),
        persist: false,
      );
    });
  }

  void stopTickerIfNotRunning() {
    if (timerState.status != PomodoroTimerStatus.running) {
      timerTicker?.cancel();
      timerTicker = null;
    }
  }

  void updateTimer(
      PomodoroTimerState Function(PomodoroTimerState state, DateTime now)
          action,
      {bool persist = true}) {
    setState(() {
      timerState = action(timerState, DateTime.now());
    });
    if (timerState.status == PomodoroTimerStatus.running) {
      startTicker();
    } else {
      stopTickerIfNotRunning();
    }
    if (persist) {
      saveTimerState();
    }
  }

  void toggleTimer() {
    updateTimer((state, now) {
      return switch (state.status) {
        PomodoroTimerStatus.idle => timerEngine.start(state, now),
        PomodoroTimerStatus.running => timerEngine.pause(state, now),
        PomodoroTimerStatus.paused => timerEngine.resume(state, now),
      };
    });
  }

  void resetTimer() {
    setState(() => timerState = timerEngine.reset(timerState));
    stopTickerIfNotRunning();
    saveTimerState();
  }

  void selectPreset(TimerPreset preset) {
    setState(() {
      activePreset = preset;
      timerEngine = PomodoroTimerEngine(config: activePreset.toTimerConfig());
      timerState = timerEngine.initialState();
    });
    timerTicker?.cancel();
    timerTicker = null;
    savePresetState();
    saveTimerState();
  }

  TimerPreset createPreset(PresetFormValues values) {
    final now = DateTime.now();
    final preset = TimerPreset(
      id: nextPresetId(presets),
      name: values.name,
      focusDuration: Duration(minutes: values.focusMinutes),
      shortBreakDuration: Duration(minutes: values.shortBreakMinutes),
      longBreakDuration: Duration(minutes: values.longBreakMinutes),
      sessionsBeforeLongBreak: values.sessionsBeforeLongBreak,
      iconKey: values.iconKey,
      cardColorKey: values.cardColorKey,
      createdAt: now,
      updatedAt: now,
    );

    setState(() => presets.add(preset));
    selectPreset(preset);
    savePresetState();
    return preset;
  }

  TimerPreset updatePreset(TimerPreset preset, PresetFormValues values) {
    final updatedPreset = preset.copyWith(
      name: values.name,
      focusDuration: Duration(minutes: values.focusMinutes),
      shortBreakDuration: Duration(minutes: values.shortBreakMinutes),
      longBreakDuration: Duration(minutes: values.longBreakMinutes),
      sessionsBeforeLongBreak: values.sessionsBeforeLongBreak,
      iconKey: values.iconKey,
      cardColorKey: values.cardColorKey,
      updatedAt: DateTime.now(),
    );

    setState(() {
      final presetIndex = presets.indexWhere(
        (currentPreset) => currentPreset.id == preset.id,
      );
      presets[presetIndex] = updatedPreset;
    });

    if (activePreset.id == preset.id) {
      selectPreset(updatedPreset);
    } else {
      savePresetState();
    }

    return updatedPreset;
  }

  TimerPreset deletePreset(TimerPreset preset) {
    final activePresets = presets.where((preset) => preset.deletedAt == null);
    if (activePresets.length <= 1) {
      return activePreset;
    }

    final wasActivePreset = activePreset.id == preset.id;
    final now = DateTime.now();
    final deletedPreset = preset.copyWith(updatedAt: now, deletedAt: now);
    final fallbackPreset = presets.firstWhere(
      (candidate) => candidate.deletedAt == null && candidate.id != preset.id,
    );

    setState(() {
      final presetIndex = presets.indexWhere(
        (currentPreset) => currentPreset.id == preset.id,
      );
      presets[presetIndex] = deletedPreset;
    });

    if (wasActivePreset) {
      selectPreset(fallbackPreset);
    } else {
      savePresetState();
    }

    return wasActivePreset ? fallbackPreset : activePreset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selectedTheme.gradient,
          ),
        ),
        child: Stack(
          children: [
            DreamyBackdrop(theme: selectedTheme),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: _PrototypeContent(
                      selectedTheme: selectedTheme,
                      timerConfig: timerEngine.config,
                      timerState: timerState,
                      onToggleTimer: toggleTimer,
                      onResetTimer: resetTimer,
                      onOpenConfiguration: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ConfigurationScreen(
                              selectedTheme: selectedTheme,
                              presets: presets,
                              activePreset: activePreset,
                              onThemeSelected: (theme) {
                                setState(() => selectedTheme = theme);
                                saveSelectedTheme();
                              },
                              onPresetSelected: selectPreset,
                              onPresetCreated: createPreset,
                              onPresetUpdated: updatePreset,
                              onPresetDeleted: deletePreset,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeContent extends StatelessWidget {
  const _PrototypeContent({
    required this.selectedTheme,
    required this.timerConfig,
    required this.timerState,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onOpenConfiguration,
  });

  final PomodoroThemeOption selectedTheme;
  final PomodoroTimerConfig timerConfig;
  final PomodoroTimerState timerState;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;
  final VoidCallback onOpenConfiguration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(theme: selectedTheme, onOpenConfiguration: onOpenConfiguration),
        const SizedBox(height: 18),
        _TimerCard(
          theme: selectedTheme,
          timerConfig: timerConfig,
          timerState: timerState,
          onToggleTimer: onToggleTimer,
          onResetTimer: onResetTimer,
        ),
        const SizedBox(height: 18),
        _PaletteCard(theme: selectedTheme),
        const SizedBox(height: 18),
        Text(
          'Theme note: ${selectedTheme.note}',
          textAlign: TextAlign.center,
          style: selectedTheme.bodyFont(
            color: selectedTheme.onPrimary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.onOpenConfiguration});

  final PomodoroThemeOption theme;
  final VoidCallback onOpenConfiguration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.card.withValues(alpha: 0.32)),
          ),
          child: Icon(theme.icon, color: theme.accent, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  theme.title,
                  key: ValueKey(theme.title),
                  style: theme.headingFont(
                    color: theme.onPrimary,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                theme.subtitle,
                style: theme.bodyFont(
                  color: theme.onPrimary.withValues(alpha: 0.84),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Open configuration',
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onOpenConfiguration,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.card.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.card.withValues(alpha: 0.32)),
              ),
              child: Icon(Icons.tune_rounded, color: theme.onPrimary, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.theme,
    required this.timerConfig,
    required this.timerState,
    required this.onToggleTimer,
    required this.onResetTimer,
  });

  final PomodoroThemeOption theme;
  final PomodoroTimerConfig timerConfig;
  final PomodoroTimerState timerState;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;

  String get primaryButtonLabel {
    return switch (timerState.status) {
      PomodoroTimerStatus.idle => 'Start',
      PomodoroTimerStatus.running => 'Pause',
      PomodoroTimerStatus.paused => 'Resume',
    };
  }

  IconData get primaryButtonIcon {
    return switch (timerState.status) {
      PomodoroTimerStatus.running => Icons.pause_rounded,
      PomodoroTimerStatus.idle ||
      PomodoroTimerStatus.paused =>
        Icons.play_arrow_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(34),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.72), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.23),
            blurRadius: 34,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SessionPill(
                label: 'Focus',
                selected: timerState.sessionType == PomodoroSessionType.focus,
                theme: theme,
              ),
              _SessionPill(
                label: 'Break',
                selected:
                    timerState.sessionType == PomodoroSessionType.shortBreak,
                theme: theme,
              ),
              _SessionPill(
                label: 'Rest',
                selected:
                    timerState.sessionType == PomodoroSessionType.longBreak,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _TimerDial(
            theme: theme,
            timerConfig: timerConfig,
            timerState: timerState,
          ),
          const SizedBox(height: 26),
          Text(
            theme.note,
            textAlign: TextAlign.center,
            style: theme.bodyFont(
              color: theme.ink.withValues(alpha: 0.68),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _CozyButton(
                  label: primaryButtonLabel,
                  icon: primaryButtonIcon,
                  background: theme.primary,
                  foreground: theme.onPrimary,
                  theme: theme,
                  onTap: onToggleTimer,
                ),
              ),
              const SizedBox(width: 12),
              _CozyButton(
                label: 'Reset',
                icon: Icons.refresh_rounded,
                background: theme.softAccent.withValues(alpha: 0.66),
                foreground: theme.ink,
                theme: theme,
                onTap: onResetTimer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionPill extends StatelessWidget {
  const _SessionPill(
      {required this.label, required this.selected, required this.theme});

  final String label;
  final bool selected;
  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      decoration: BoxDecoration(
        color: selected
            ? theme.secondary.withValues(alpha: 0.68)
            : Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.bodyFont(
          color: theme.ink,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({
    required this.theme,
    required this.timerConfig,
    required this.timerState,
  });

  final PomodoroThemeOption theme;
  final PomodoroTimerConfig timerConfig;
  final PomodoroTimerState timerState;

  String get sessionLabel {
    return switch (timerState.sessionType) {
      PomodoroSessionType.focus => 'deep focus',
      PomodoroSessionType.shortBreak => 'short break',
      PomodoroSessionType.longBreak => 'long rest',
    };
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = timerState.remainingAt(now, timerConfig);
    final progress = timerState.progressAt(now, timerConfig);

    return SizedBox(
      width: 238,
      height: 238,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(238),
            painter: _MoonProgressPainter(progress: progress, theme: theme),
          ),
          Container(
            width: 178,
            height: 178,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.82),
                  theme.softAccent.withValues(alpha: 0.34)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.secondary.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatRemainingForDisplay(remaining),
                style: theme.headingFont(
                  color: theme.ink,
                  fontSize: 53,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.2,
                ),
              ),
              Text(
                sessionLabel,
                style: theme.bodyFont(
                  color: theme.ink.withValues(alpha: 0.58),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoonProgressPainter extends CustomPainter {
  const _MoonProgressPainter({required this.progress, required this.theme});

  final double progress;
  final PomodoroThemeOption theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 13;
    final basePaint = Paint()
      ..color = theme.softAccent.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;
    final progressPaint = Paint()
      ..color = theme.softAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.theme != theme;
  }
}

class _CozyButton extends StatelessWidget {
  const _CozyButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.theme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final PomodoroThemeOption theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(19),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: background.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 24),
            const SizedBox(width: 7),
            Text(
              label,
              style: theme.bodyFont(
                color: foreground,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({required this.theme});

  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.card.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Palette + Type',
            style: theme.headingFont(
              color: theme.onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final swatch in theme.palette)
                _ColorChip(swatch, theme: theme)
            ],
          ),
          const SizedBox(height: 14),
          Text(
            theme.typeNote,
            style: theme.bodyFont(
              color: theme.onPrimary.withValues(alpha: 0.88),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.swatch, {required this.theme});

  final PaletteSwatch swatch;
  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    final isLight = swatch.color.computeLuminance() > 0.65;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: swatch.color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Text(
        swatch.label,
        style: theme.bodyFont(
          color: isLight ? theme.ink : theme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
