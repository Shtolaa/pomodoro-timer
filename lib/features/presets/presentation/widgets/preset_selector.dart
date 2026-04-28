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
  });

  final PomodoroThemeOption theme;
  final List<TimerPreset> presets;
  final TimerPreset activePreset;
  final ValueChanged<TimerPreset> onPresetSelected;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Timer Preset',
            style: theme.headingFont(
              color: theme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
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
          for (final preset in presets) ...[
            _PresetCard(
              theme: theme,
              preset: preset,
              selected: preset.id == activePreset.id,
              onTap: () => onPresetSelected(preset),
            ),
            if (preset != presets.last) const SizedBox(height: 12),
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
    required this.onTap,
  });

  final PomodoroThemeOption theme;
  final TimerPreset preset;
  final bool selected;
  final VoidCallback onTap;

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
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: cardColor.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                          'Classic 25/5 focus rhythm with a generous long rest.',
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
                  if (selected)
                    Icon(Icons.check_circle_rounded,
                        color: theme.primary, size: 25),
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
