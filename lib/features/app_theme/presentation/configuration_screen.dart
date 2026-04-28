import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/dreamy_backdrop.dart';
import '../../presets/domain/timer_preset.dart';
import '../../presets/presentation/preset_form_screen.dart';
import '../../presets/presentation/preset_presentation_mappers.dart';
import '../../presets/presentation/widgets/preset_selector.dart';
import '../../statistics/domain/focus_session_record.dart';
import '../domain/pomodoro_theme.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({
    super.key,
    required this.selectedTheme,
    required this.presets,
    required this.activePreset,
    required this.focusSessionRecords,
    required this.notificationsEnabled,
    required this.onThemeSelected,
    required this.onPresetSelected,
    required this.onPresetCreated,
    required this.onPresetUpdated,
    required this.onPresetDeleted,
    required this.onDeletedPresetStatisticsDeleted,
    required this.onNotificationsEnabledChanged,
  });

  final PomodoroThemeOption selectedTheme;
  final List<TimerPreset> presets;
  final TimerPreset activePreset;
  final List<FocusSessionRecord> focusSessionRecords;
  final bool notificationsEnabled;
  final ValueChanged<PomodoroThemeOption> onThemeSelected;
  final ValueChanged<TimerPreset> onPresetSelected;
  final TimerPreset Function(PresetFormValues values) onPresetCreated;
  final TimerPreset Function(TimerPreset preset, PresetFormValues values)
      onPresetUpdated;
  final TimerPreset Function(TimerPreset preset) onPresetDeleted;
  final ValueChanged<int> onDeletedPresetStatisticsDeleted;
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
                        _StatisticsCard(
                          theme: selectedTheme,
                          records: widget.focusSessionRecords,
                          presets: widget.presets,
                          onDeletedPresetStatisticsDeleted: (presetId) {
                            widget.onDeletedPresetStatisticsDeleted(presetId);
                            setState(() {});
                          },
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

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({
    required this.theme,
    required this.records,
    required this.presets,
    required this.onDeletedPresetStatisticsDeleted,
  });

  final PomodoroThemeOption theme;
  final List<FocusSessionRecord> records;
  final List<TimerPreset> presets;
  final ValueChanged<int> onDeletedPresetStatisticsDeleted;

  @override
  Widget build(BuildContext context) {
    final summaries = focusSessionSummariesByPreset(records);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.card.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.softAccent.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(19),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.5)),
                ),
                child: Icon(Icons.insights_rounded, color: theme.ink, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: theme.headingFont(
                        color: theme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed focus sessions only. Breaks stay cozy and uncounted.',
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatisticTotalTile(
                  theme: theme,
                  label: 'Sessions',
                  value: completedFocusSessionCount(records).toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatisticTotalTile(
                  theme: theme,
                  label: 'Focus time',
                  value: _formatFocusDuration(totalFocusDuration(records)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (summaries.isEmpty)
            Text(
              'No completed focus sessions yet.',
              style: theme.bodyFont(
                color: theme.onPrimary.withValues(alpha: 0.78),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            )
          else
            for (final summary in summaries) ...[
              _PresetStatisticRow(
                theme: theme,
                summary: summary,
                deletedPreset: _isDeletedPreset(summary.presetId),
                onDelete: summary.presetId == null
                    ? null
                    : () => _confirmDeleteHistoricalStatistics(
                          context,
                          summary,
                        ),
              ),
              if (summary != summaries.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  bool _isDeletedPreset(int? presetId) {
    return presets.any(
      (preset) => preset.id == presetId && preset.deletedAt != null,
    );
  }

  Future<void> _confirmDeleteHistoricalStatistics(
    BuildContext context,
    FocusSessionPresetSummary summary,
  ) async {
    if (!_isDeletedPreset(summary.presetId)) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.56)),
          ),
          title: Text(
            'Delete ${summary.presetNameSnapshot} statistics?',
            style: theme.headingFont(
              color: theme.ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'This permanently removes historical focus statistics for this deleted preset.',
            style: theme.bodyFont(
              color: theme.ink.withValues(alpha: 0.72),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: theme.bodyFont(fontWeight: FontWeight.w900),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
              ),
              child: Text(
                'Delete stats',
                style: theme.bodyFont(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      onDeletedPresetStatisticsDeleted(summary.presetId!);
    }
  }
}

class _StatisticTotalTile extends StatelessWidget {
  const _StatisticTotalTile({
    required this.theme,
    required this.label,
    required this.value,
  });

  final PomodoroThemeOption theme;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.headingFont(
              color: theme.ink,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.bodyFont(
              color: theme.ink.withValues(alpha: 0.64),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetStatisticRow extends StatelessWidget {
  const _PresetStatisticRow({
    required this.theme,
    required this.summary,
    required this.deletedPreset,
    required this.onDelete,
  });

  final PomodoroThemeOption theme;
  final FocusSessionPresetSummary summary;
  final bool deletedPreset;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cardColor = colorForPresetColorKey(summary.presetColorSnapshot);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Icon(
              iconForPresetIconKey(summary.presetIconSnapshot),
              color: theme.ink,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.presetNameSnapshot,
                  style: theme.bodyFont(
                    color: theme.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${summary.sessionsCompleted} sessions - ${_formatFocusDuration(summary.totalDuration)}',
                  style: theme.bodyFont(
                    color: theme.ink.withValues(alpha: 0.66),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (deletedPreset) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Deleted preset history',
                    style: theme.bodyFont(
                      color: theme.ink.withValues(alpha: 0.52),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (deletedPreset)
            Tooltip(
              message: 'Delete ${summary.presetNameSnapshot} statistics',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onDelete,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.softAccent.withValues(alpha: 0.38),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.ink.withValues(alpha: 0.78),
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatFocusDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours;
  final remainingHours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);

  if (days > 0) {
    if (remainingHours == 0) {
      return '${days}d';
    }
    return '${days}d ${remainingHours}h';
  }

  if (hours == 0) {
    return '${minutes}m';
  }
  if (minutes == 0) {
    return '${hours}h';
  }
  return '${hours}h ${minutes}m';
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
