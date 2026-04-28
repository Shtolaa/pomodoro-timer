import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'timer_engine.dart';

void main() {
  runApp(const CozyPomodoroApp());
}

class CozyPomodoroApp extends StatelessWidget {
  const CozyPomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cozy Pomodoro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PomodoroThemeOption.themes.first.primary,
          brightness: Brightness.light,
        ),
      ),
      home: const ThemePrototypeScreen(),
    );
  }
}

class PomodoroThemeOption {
  const PomodoroThemeOption({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.note,
    required this.typeNote,
    required this.icon,
    required this.gradient,
    required this.card,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.softAccent,
    required this.ink,
    required this.onPrimary,
    required this.palette,
    required this.headingFont,
    required this.bodyFont,
  });

  final String name;
  final String title;
  final String subtitle;
  final String note;
  final String typeNote;
  final IconData icon;
  final List<Color> gradient;
  final Color card;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color softAccent;
  final Color ink;
  final Color onPrimary;
  final List<PaletteSwatch> palette;
  final TextStyle Function(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing}) headingFont;
  final TextStyle Function(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height}) bodyFont;

  static final themes = [
    PomodoroThemeOption(
      name: 'Moonlit Pastel',
      title: 'Moonlit Pomodoro',
      subtitle: 'A quiet timer for soft-focus nights',
      note: 'Light a candle, choose one task, and let the room get quiet.',
      typeNote: 'Fraunces for timer and headings. Nunito for labels and notes.',
      icon: Icons.nightlight_round,
      gradient: const [Color(0xFF5C537A), Color(0xFF9B82A7), Color(0xFFE9C4C8)],
      card: const Color(0xFFFFF7EA),
      primary: const Color(0xFF4E4668),
      secondary: const Color(0xFFD9B4C7),
      accent: const Color(0xFFFFE8A8),
      softAccent: const Color(0xFFC7B7E8),
      ink: const Color(0xFF332D42),
      onPrimary: const Color(0xFFFFF7EA),
      palette: const [
        PaletteSwatch('Night', Color(0xFF4E4668)),
        PaletteSwatch('Lilac', Color(0xFFC7B7E8)),
        PaletteSwatch('Mauve', Color(0xFFD9B4C7)),
        PaletteSwatch('Cream', Color(0xFFFFF7EA)),
        PaletteSwatch('Moon', Color(0xFFFFE8A8)),
        PaletteSwatch('Sage', Color(0xFFC8D9C1)),
      ],
      headingFont: GoogleFonts.fraunces,
      bodyFont: GoogleFonts.nunito,
    ),
    PomodoroThemeOption(
      name: 'Cottage Calm',
      title: 'Cottage Pomodoro',
      subtitle: 'Tea, herbs, and one gentle task',
      note:
          'Settle near the window, breathe slowly, and work like the kettle is almost ready.',
      typeNote:
          'Cormorant Garamond for headings. Nunito Sans for a friendly reading rhythm.',
      icon: Icons.local_florist_rounded,
      gradient: const [Color(0xFF9EB69A), Color(0xFFE5C6B2), Color(0xFFFFF1D6)],
      card: const Color(0xFFFFF8E8),
      primary: const Color(0xFF5B7452),
      secondary: const Color(0xFFE9B7AE),
      accent: const Color(0xFFF6D89B),
      softAccent: const Color(0xFFC8D9B9),
      ink: const Color(0xFF3C3328),
      onPrimary: const Color(0xFFFFF8E8),
      palette: const [
        PaletteSwatch('Sage', Color(0xFF5B7452)),
        PaletteSwatch('Herb', Color(0xFFC8D9B9)),
        PaletteSwatch('Blush', Color(0xFFE9B7AE)),
        PaletteSwatch('Cream', Color(0xFFFFF8E8)),
        PaletteSwatch('Honey', Color(0xFFF6D89B)),
        PaletteSwatch('Soil', Color(0xFF3C3328)),
      ],
      headingFont: GoogleFonts.cormorantGaramond,
      bodyFont: GoogleFonts.nunitoSans,
    ),
    PomodoroThemeOption(
      name: 'Peach Cafe',
      title: 'Cafe Pomodoro',
      subtitle: 'Warm focus with a sweet table glow',
      note:
          'Sip something warm, clear the table, and let the next twenty-five minutes feel handmade.',
      typeNote:
          'Young Serif gives the timer a menu-card feel. Quicksand keeps controls soft.',
      icon: Icons.local_cafe_rounded,
      gradient: const [Color(0xFFB98268), Color(0xFFF0B58E), Color(0xFFFFE3C4)],
      card: const Color(0xFFFFF2DF),
      primary: const Color(0xFF6D4638),
      secondary: const Color(0xFFF1A58D),
      accent: const Color(0xFFFFCF86),
      softAccent: const Color(0xFFF8C8B2),
      ink: const Color(0xFF3E2B25),
      onPrimary: const Color(0xFFFFF2DF),
      palette: const [
        PaletteSwatch('Cocoa', Color(0xFF6D4638)),
        PaletteSwatch('Peach', Color(0xFFF1A58D)),
        PaletteSwatch('Foam', Color(0xFFFFF2DF)),
        PaletteSwatch('Honey', Color(0xFFFFCF86)),
        PaletteSwatch('Rose', Color(0xFFF8C8B2)),
        PaletteSwatch('Bean', Color(0xFF3E2B25)),
      ],
      headingFont: GoogleFonts.youngSerif,
      bodyFont: GoogleFonts.quicksand,
    ),
    PomodoroThemeOption(
      name: 'Cloud Nap',
      title: 'Cloud Pomodoro',
      subtitle: 'Floaty focus for quiet afternoons',
      note:
          'Let the timer drift, keep the task tiny, and give your mind a soft place to land.',
      typeNote:
          'Playfair Display adds airy elegance. Plus Jakarta Sans keeps labels crisp.',
      icon: Icons.cloud_rounded,
      gradient: const [Color(0xFF8FB8D9), Color(0xFFC9C6F0), Color(0xFFFFDDE8)],
      card: const Color(0xFFFFFAFE),
      primary: const Color(0xFF536D92),
      secondary: const Color(0xFFC8BFF0),
      accent: const Color(0xFFFFD7A8),
      softAccent: const Color(0xFFBFDDF0),
      ink: const Color(0xFF2F3856),
      onPrimary: const Color(0xFFFFFAFE),
      palette: const [
        PaletteSwatch('Sky', Color(0xFF536D92)),
        PaletteSwatch('Cloud', Color(0xFFFFFAFE)),
        PaletteSwatch('Lilac', Color(0xFFC8BFF0)),
        PaletteSwatch('Blue', Color(0xFFBFDDF0)),
        PaletteSwatch('Peach', Color(0xFFFFD7A8)),
        PaletteSwatch('Ink', Color(0xFF2F3856)),
      ],
      headingFont: GoogleFonts.playfairDisplay,
      bodyFont: GoogleFonts.plusJakartaSans,
    ),
  ];
}

class PaletteSwatch {
  const PaletteSwatch(this.label, this.color);

  final String label;
  final Color color;
}

class ThemePrototypeScreen extends StatefulWidget {
  const ThemePrototypeScreen({super.key});

  @override
  State<ThemePrototypeScreen> createState() => _ThemePrototypeScreenState();
}

class _ThemePrototypeScreenState extends State<ThemePrototypeScreen> {
  PomodoroThemeOption selectedTheme = PomodoroThemeOption.themes.first;
  final PomodoroTimerEngine timerEngine = const PomodoroTimerEngine();
  late PomodoroTimerState timerState = timerEngine.initialState();
  Timer? timerTicker;

  @override
  void dispose() {
    timerTicker?.cancel();
    super.dispose();
  }

  void startTicker() {
    timerTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      updateTimer((state, now) => timerEngine.advanceTo(state, now));
    });
  }

  void stopTickerIfNotRunning() {
    if (timerState.status != PomodoroTimerStatus.running) {
      timerTicker?.cancel();
      timerTicker = null;
    }
  }

  void updateTimer(
    PomodoroTimerState Function(PomodoroTimerState state, DateTime now) action,
  ) {
    setState(() {
      timerState = action(timerState, DateTime.now());
    });
    if (timerState.status == PomodoroTimerStatus.running) {
      startTicker();
    } else {
      stopTickerIfNotRunning();
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
            _DreamyBackdrop(theme: selectedTheme),
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
                              onThemeSelected: (theme) {
                                setState(() => selectedTheme = theme);
                              },
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

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({
    super.key,
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  final PomodoroThemeOption selectedTheme;
  final ValueChanged<PomodoroThemeOption> onThemeSelected;

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late PomodoroThemeOption selectedTheme = widget.selectedTheme;

  void selectTheme(PomodoroThemeOption theme) {
    setState(() => selectedTheme = theme);
    widget.onThemeSelected(theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
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
            _DreamyBackdrop(theme: selectedTheme),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ConfigurationHeader(theme: selectedTheme),
                        const SizedBox(height: 22),
                        _ThemeListSelector(
                          selectedTheme: selectedTheme,
                          onThemeSelected: selectTheme,
                        ),
                      ],
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

class _ConfigurationHeader extends StatelessWidget {
  const _ConfigurationHeader({required this.theme});

  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.card.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.card.withValues(alpha: 0.32)),
            ),
            child: Icon(Icons.arrow_back_rounded, color: theme.onPrimary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration',
                style: theme.headingFont(
                  color: theme.onPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tune the feeling of your focus space',
                style: theme.bodyFont(
                  color: theme.onPrimary.withValues(alpha: 0.84),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeListSelector extends StatelessWidget {
  const _ThemeListSelector(
      {required this.selectedTheme, required this.onThemeSelected});

  final PomodoroThemeOption selectedTheme;
  final ValueChanged<PomodoroThemeOption> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selectedTheme.card.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: selectedTheme.card.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Theme',
            style: selectedTheme.headingFont(
              color: selectedTheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep all four moods and choose the one that feels best for the timer.',
            style: selectedTheme.bodyFont(
              color: selectedTheme.onPrimary.withValues(alpha: 0.84),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          for (final theme in PomodoroThemeOption.themes) ...[
            _ThemeListCard(
              theme: theme,
              selected: theme.name == selectedTheme.name,
              currentTheme: selectedTheme,
              onTap: () => onThemeSelected(theme),
            ),
            if (theme != PomodoroThemeOption.themes.last)
              const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ThemeListCard extends StatelessWidget {
  const _ThemeListCard({
    required this.theme,
    required this.selected,
    required this.currentTheme,
    required this.onTap,
  });

  final PomodoroThemeOption theme;
  final PomodoroThemeOption currentTheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Select ${theme.name} theme',
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: currentTheme.card.withValues(alpha: selected ? 0.92 : 0.54),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected
                  ? theme.accent
                  : currentTheme.card.withValues(alpha: 0.34),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: theme.accent.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.primary, theme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(theme.icon, color: theme.onPrimary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: currentTheme.bodyFont(
                            color: currentTheme.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          theme.subtitle,
                          style: currentTheme.bodyFont(
                            color: currentTheme.ink.withValues(alpha: 0.64),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        color: theme.primary, size: 24),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final color in [
                    theme.primary,
                    theme.secondary,
                    theme.accent,
                    theme.softAccent
                  ])
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.68)),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '18:42',
                    style: theme.headingFont(
                      color: currentTheme.ink,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  String formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

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
                formatRemaining(remaining),
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
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [theme.accent, theme.secondary, theme.softAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
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

    final moonPaint = Paint()..color = theme.accent;
    canvas.drawCircle(Offset(center.dx + 78, center.dy - 74), 7, moonPaint);
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

class _DreamyBackdrop extends StatelessWidget {
  const _DreamyBackdrop({required this.theme});

  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 72,
          right: 36,
          child:
              _GlowOrb(size: 98, color: theme.accent.withValues(alpha: 0.54)),
        ),
        Positioned(
          top: 138,
          left: -34,
          child: _GlowOrb(
              size: 160, color: theme.softAccent.withValues(alpha: 0.36)),
        ),
        Positioned(
          bottom: 88,
          right: -42,
          child: _GlowOrb(
              size: 190, color: theme.secondary.withValues(alpha: 0.35)),
        ),
        _Star(top: 98, left: 60, size: 5, theme: theme),
        _Star(top: 182, right: 84, size: 4, theme: theme),
        _Star(bottom: 182, left: 44, size: 6, theme: theme),
        _Star(bottom: 60, right: 126, size: 4, theme: theme),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 42, spreadRadius: 14)],
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star(
      {this.top,
      this.right,
      this.bottom,
      this.left,
      required this.size,
      required this.theme});

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final PomodoroThemeOption theme;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(1.4),
            boxShadow: [
              BoxShadow(
                color: theme.card.withValues(alpha: 0.55),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
