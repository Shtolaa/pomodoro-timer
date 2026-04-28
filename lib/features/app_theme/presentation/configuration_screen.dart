import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/dreamy_backdrop.dart';
import '../../presets/domain/timer_preset.dart';
import '../../presets/presentation/preset_form_screen.dart';
import '../../presets/presentation/widgets/preset_selector.dart';
import '../domain/pomodoro_theme.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({
    super.key,
    required this.selectedTheme,
    required this.presets,
    required this.activePreset,
    required this.notificationsEnabled,
    required this.onThemeSelected,
    required this.onPresetSelected,
    required this.onPresetCreated,
    required this.onPresetUpdated,
    required this.onPresetDeleted,
    required this.onNotificationsEnabledChanged,
  });

  final PomodoroThemeOption selectedTheme;
  final List<TimerPreset> presets;
  final TimerPreset activePreset;
  final bool notificationsEnabled;
  final ValueChanged<PomodoroThemeOption> onThemeSelected;
  final ValueChanged<TimerPreset> onPresetSelected;
  final TimerPreset Function(PresetFormValues values) onPresetCreated;
  final TimerPreset Function(TimerPreset preset, PresetFormValues values)
      onPresetUpdated;
  final TimerPreset Function(TimerPreset preset) onPresetDeleted;
  final Future<bool> Function(bool enabled) onNotificationsEnabledChanged;

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  late PomodoroThemeOption selectedTheme = widget.selectedTheme;
  late TimerPreset activePreset = widget.activePreset;
  late bool notificationsEnabled = widget.notificationsEnabled;
  bool updatingNotifications = false;

  void selectTheme(PomodoroThemeOption theme) {
    setState(() => selectedTheme = theme);
    widget.onThemeSelected(theme);
  }

  void selectPreset(TimerPreset preset) {
    setState(() => activePreset = preset);
    widget.onPresetSelected(preset);
  }

  Future<void> createPreset() async {
    final values = await Navigator.of(context).push<PresetFormValues>(
      MaterialPageRoute(
        builder: (_) => PresetFormScreen(theme: selectedTheme),
      ),
    );
    if (values == null || !mounted) {
      return;
    }

    setState(() => activePreset = widget.onPresetCreated(values));
  }

  Future<void> editPreset(TimerPreset preset) async {
    final values = await Navigator.of(context).push<PresetFormValues>(
      MaterialPageRoute(
        builder: (_) => PresetFormScreen(
          theme: selectedTheme,
          initialPreset: preset,
        ),
      ),
    );
    if (values == null || !mounted) {
      return;
    }

    final updatedPreset = widget.onPresetUpdated(preset, values);
    if (activePreset.id == updatedPreset.id) {
      setState(() => activePreset = updatedPreset);
    }
  }

  void deletePreset(TimerPreset preset) {
    setState(() => activePreset = widget.onPresetDeleted(preset));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    setState(() => updatingNotifications = true);
    final nextEnabled = await widget.onNotificationsEnabledChanged(enabled);
    if (!mounted) {
      return;
    }
    if (enabled && !nextEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notifications could not be enabled. Check Android notification permission.',
            style: selectedTheme.bodyFont(fontWeight: FontWeight.w800),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() {
      notificationsEnabled = nextEnabled;
      updatingNotifications = false;
    });
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
            DreamyBackdrop(theme: selectedTheme),
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
                        PresetSelector(
                          theme: selectedTheme,
                          presets: widget.presets,
                          activePreset: activePreset,
                          onPresetSelected: selectPreset,
                          onCreatePreset: createPreset,
                          onEditPreset: editPreset,
                          onDeletePreset: deletePreset,
                        ),
                        const SizedBox(height: 18),
                        _NotificationSettingsCard(
                          theme: selectedTheme,
                          notificationsEnabled: notificationsEnabled,
                          updating: updatingNotifications,
                          onChanged: setNotificationsEnabled,
                        ),
                        const SizedBox(height: 18),
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

class _NotificationSettingsCard extends StatelessWidget {
  const _NotificationSettingsCard({
    required this.theme,
    required this.notificationsEnabled,
    required this.updating,
    required this.onChanged,
  });

  final PomodoroThemeOption theme;
  final bool notificationsEnabled;
  final bool updating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.card.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.softAccent.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.notifications_active_rounded,
                color: theme.ink, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: theme.headingFont(
                    color: theme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notificationsEnabled
                      ? 'Session-end notes are scheduled when the timer runs.'
                      : 'Ask Android before sending gentle session transition notes.',
                  style: theme.bodyFont(
                    color: theme.onPrimary.withValues(alpha: 0.84),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: notificationsEnabled,
            onChanged: updating ? null : onChanged,
            activeThumbColor: theme.accent,
            activeTrackColor: theme.softAccent.withValues(alpha: 0.72),
            inactiveThumbColor: theme.card,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.34),
          ),
        ],
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
