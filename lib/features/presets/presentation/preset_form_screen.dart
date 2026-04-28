import 'package:flutter/material.dart';

import '../../app_theme/domain/pomodoro_theme.dart';
import '../domain/preset_color_key.dart';
import '../domain/preset_icon_key.dart';
import '../domain/timer_preset.dart';
import 'preset_presentation_mappers.dart';

class PresetFormValues {
  const PresetFormValues({
    required this.name,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.sessionsBeforeLongBreak,
    required this.iconKey,
    required this.cardColorKey,
  });

  final String name;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final PresetIconKey iconKey;
  final PresetColorKey cardColorKey;
}

class PresetFormScreen extends StatefulWidget {
  const PresetFormScreen({
    super.key,
    required this.theme,
    this.initialPreset,
  });

  final PomodoroThemeOption theme;
  final TimerPreset? initialPreset;

  @override
  State<PresetFormScreen> createState() => _PresetFormScreenState();
}

class _PresetFormScreenState extends State<PresetFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController focusController;
  late final TextEditingController shortBreakController;
  late final TextEditingController longBreakController;
  late final TextEditingController sessionsController;
  late PresetIconKey selectedIconKey;
  late PresetColorKey selectedColorKey;

  bool get isEditing => widget.initialPreset != null;

  @override
  void initState() {
    super.initState();
    final preset = widget.initialPreset;
    nameController = TextEditingController(text: preset?.name ?? '');
    focusController = TextEditingController(
      text: (preset?.focusDuration.inMinutes ?? 25).toString(),
    );
    shortBreakController = TextEditingController(
      text: (preset?.shortBreakDuration.inMinutes ?? 5).toString(),
    );
    longBreakController = TextEditingController(
      text: (preset?.longBreakDuration.inMinutes ?? 30).toString(),
    );
    sessionsController = TextEditingController(
      text: (preset?.sessionsBeforeLongBreak ?? 4).toString(),
    );
    selectedIconKey = preset?.iconKey ?? PresetIconKey.book;
    selectedColorKey = preset?.cardColorKey ?? PresetColorKey.peach;
  }

  @override
  void dispose() {
    nameController.dispose();
    focusController.dispose();
    shortBreakController.dispose();
    longBreakController.dispose();
    sessionsController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validatePositiveInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Use a positive number';
    }
    return null;
  }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      PresetFormValues(
        name: nameController.text.trim(),
        focusMinutes: int.parse(focusController.text.trim()),
        shortBreakMinutes: int.parse(shortBreakController.text.trim()),
        longBreakMinutes: int.parse(longBreakController.text.trim()),
        sessionsBeforeLongBreak: int.parse(sessionsController.text.trim()),
        iconKey: selectedIconKey,
        cardColorKey: selectedColorKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PresetFormHeader(
                        theme: theme,
                        title: isEditing ? 'Edit Preset' : 'New Preset',
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: theme.card.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.68),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.2),
                              blurRadius: 28,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CozyTextField(
                              theme: theme,
                              label: 'Preset name',
                              controller: nameController,
                              validator: validateName,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _CozyTextField(
                                    theme: theme,
                                    label: 'Focus minutes',
                                    controller: focusController,
                                    validator: validatePositiveInt,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _CozyTextField(
                                    theme: theme,
                                    label: 'Short break',
                                    controller: shortBreakController,
                                    validator: validatePositiveInt,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _CozyTextField(
                                    theme: theme,
                                    label: 'Long break',
                                    controller: longBreakController,
                                    validator: validatePositiveInt,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _CozyTextField(
                                    theme: theme,
                                    label: 'Sessions',
                                    controller: sessionsController,
                                    validator: validatePositiveInt,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _ChoiceSection(
                              theme: theme,
                              title: 'Icon',
                              children: [
                                for (final key in PresetIconKey.values)
                                  _IconChoice(
                                    theme: theme,
                                    iconKey: key,
                                    selected: key == selectedIconKey,
                                    onTap: () => setState(
                                      () => selectedIconKey = key,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _ChoiceSection(
                              theme: theme,
                              title: 'Card color',
                              children: [
                                for (final key in PresetColorKey.values)
                                  _ColorChoice(
                                    theme: theme,
                                    colorKey: key,
                                    selected: key == selectedColorKey,
                                    onTap: () => setState(
                                      () => selectedColorKey = key,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: save,
                              icon: const Icon(Icons.check_rounded),
                              label: Text(
                                  isEditing ? 'Save preset' : 'Create preset'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: theme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 15,
                                ),
                                textStyle: theme.bodyFont(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetFormHeader extends StatelessWidget {
  const _PresetFormHeader({required this.theme, required this.title});

  final PomodoroThemeOption theme;
  final String title;

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
                title,
                style: theme.headingFont(
                  color: theme.onPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Shape a gentle rhythm for this kind of work',
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

class _CozyTextField extends StatelessWidget {
  const _CozyTextField({
    required this.theme,
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  final PomodoroThemeOption theme;
  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: theme.bodyFont(
        color: theme.ink,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.bodyFont(
          color: theme.ink.withValues(alpha: 0.62),
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.56)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.56)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: theme.primary, width: 2),
        ),
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  const _ChoiceSection({
    required this.theme,
    required this.title,
    required this.children,
  });

  final PomodoroThemeOption theme;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.bodyFont(
            color: theme.ink,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: children),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.theme,
    required this.iconKey,
    required this.selected,
    required this.onTap,
  });

  final PomodoroThemeOption theme;
  final PresetIconKey iconKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose ${iconKey.name} preset icon',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? theme.softAccent.withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? theme.primary
                  : Colors.white.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Icon(iconForPresetIconKey(iconKey), color: theme.ink),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.theme,
    required this.colorKey,
    required this.selected,
    required this.onTap,
  });

  final PomodoroThemeOption theme;
  final PresetColorKey colorKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorForPresetColorKey(colorKey);

    return Semantics(
      button: true,
      selected: selected,
      label: 'Choose ${colorKey.name} preset color',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? theme.primary
                  : Colors.white.withValues(alpha: 0.72),
              width: selected ? 3 : 1.4,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: color.withValues(alpha: 0.42),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
