import 'package:flutter/material.dart';

import '../../../app_theme/domain/pomodoro_theme.dart';
import '../../domain/timer_preset.dart';
import '../preset_presentation_mappers.dart';

class PresetSelector extends StatelessWidget {
  const PresetSelector({
    super.key,
    required this.theme,
    required this.presets,
    required this.activePreset,
    required this.onPresetSelected,
    required this.onCreatePreset,
    required this.onEditPreset,
    required this.onDeletePreset,
  });

  final PomodoroThemeOption theme;
  final List<TimerPreset> presets;
  final TimerPreset activePreset;
  final ValueChanged<TimerPreset> onPresetSelected;
  final VoidCallback onCreatePreset;
  final ValueChanged<TimerPreset> onEditPreset;
  final ValueChanged<TimerPreset> onDeletePreset;

  @override
  Widget build(BuildContext context) {
    final activePresets = presets
        .where((preset) => preset.deletedAt == null)
        .toList(growable: false);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Timer Preset',
                  style: theme.headingFont(
                    color: theme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _CreatePresetButton(theme: theme, onTap: onCreatePreset),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the rhythm for focus, breaks, and long rests.',
            style: theme.bodyFont(
              color: theme.onPrimary.withValues(alpha: 0.84),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          for (final preset in activePresets) ...[
            _PresetCard(
              theme: theme,
              preset: preset,
              selected: preset.id == activePreset.id,
              canDelete: activePresets.length > 1,
              onTap: () => onPresetSelected(preset),
              onEdit: () => onEditPreset(preset),
              onDelete: () => onDeletePreset(preset),
            ),
            if (preset != activePresets.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.theme,
    required this.preset,
    required this.selected,
    required this.canDelete,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PomodoroThemeOption theme;
  final TimerPreset preset;
  final bool selected;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Future<void> confirmDelete(BuildContext context) async {
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
            'Delete "${preset.name}"?',
            style: theme.headingFont(
              color: theme.ink,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'This removes the preset from selection. Historical statistics will stay available when stats are added.',
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
                'Delete',
                style: theme.bodyFont(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = colorForPresetColorKey(preset.cardColorKey);
    final icon = iconForPresetIconKey(preset.iconKey);

    return Semantics(
      button: true,
      selected: selected,
      label: 'Select ${preset.name} timer preset',
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: selected ? 0.94 : 0.58),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? cardColor : theme.card.withValues(alpha: 0.36),
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.4),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
              if (selected)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.55),
                  blurRadius: 0,
                  spreadRadius: 1.4,
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cardColor,
                          Color.lerp(cardColor, theme.card, 0.46)!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                    ),
                    child: Icon(icon, color: theme.ink, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: theme.bodyFont(
                            color: theme.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${preset.focusDuration.inMinutes}/${preset.shortBreakDuration.inMinutes} rhythm with ${preset.longBreakDuration.inMinutes} min long rests.',
                          style: theme.bodyFont(
                            color: theme.ink.withValues(alpha: 0.64),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PresetActionButton(
                        theme: theme,
                        tooltip: 'Edit ${preset.name}',
                        icon: Icons.edit_rounded,
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 4),
                      _PresetActionButton(
                        theme: theme,
                        tooltip: canDelete
                            ? 'Delete ${preset.name}'
                            : 'Delete unavailable: only one preset remains',
                        icon: Icons.delete_outline_rounded,
                        onTap: canDelete ? () => confirmDelete(context) : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetMetricChip(
                    theme: theme,
                    label: '${preset.focusDuration.inMinutes} min focus',
                  ),
                  _PresetMetricChip(
                    theme: theme,
                    label: '${preset.shortBreakDuration.inMinutes} min break',
                  ),
                  _PresetMetricChip(
                    theme: theme,
                    label:
                        '${preset.longBreakDuration.inMinutes} min long rest',
                  ),
                  _PresetMetricChip(
                    theme: theme,
                    label: '${preset.sessionsBeforeLongBreak} sessions',
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

class _CreatePresetButton extends StatelessWidget {
  const _CreatePresetButton({required this.theme, required this.onTap});

  final PomodoroThemeOption theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Create preset',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: theme.card.withValues(alpha: 0.64),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.46)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: theme.ink, size: 19),
              const SizedBox(width: 5),
              Text(
                'New',
                style: theme.bodyFont(
                  color: theme.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetActionButton extends StatelessWidget {
  const _PresetActionButton({
    required this.theme,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final PomodoroThemeOption theme;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: onTap == null
                ? Colors.white.withValues(alpha: 0.2)
                : theme.softAccent.withValues(alpha: 0.38),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
          ),
          child: Icon(
            icon,
            color: theme.ink.withValues(alpha: onTap == null ? 0.34 : 0.78),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _PresetMetricChip extends StatelessWidget {
  const _PresetMetricChip({required this.theme, required this.label});

  final PomodoroThemeOption theme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.softAccent.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Text(
        label,
        style: theme.bodyFont(
          color: theme.ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
