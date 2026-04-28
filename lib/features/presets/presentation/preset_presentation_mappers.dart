import 'package:flutter/material.dart';

import '../domain/preset_color_key.dart';
import '../domain/preset_icon_key.dart';

IconData iconForPresetIconKey(PresetIconKey key) {
  return switch (key) {
    PresetIconKey.book => Icons.menu_book_rounded,
    PresetIconKey.meditation => Icons.self_improvement_rounded,
    PresetIconKey.coffee => Icons.local_cafe_rounded,
    PresetIconKey.laptop => Icons.laptop_mac_rounded,
    PresetIconKey.dumbbell => Icons.fitness_center_rounded,
    PresetIconKey.music => Icons.music_note_rounded,
    PresetIconKey.palette => Icons.palette_rounded,
    PresetIconKey.moon => Icons.nightlight_round,
  };
}

Color colorForPresetColorKey(PresetColorKey key) {
  return switch (key) {
    PresetColorKey.lavender => const Color(0xFFC7B7E8),
    PresetColorKey.sage => const Color(0xFFC8D9B9),
    PresetColorKey.blush => const Color(0xFFE9B7AE),
    PresetColorKey.honey => const Color(0xFFF6D89B),
    PresetColorKey.peach => const Color(0xFFF1A58D),
    PresetColorKey.powderBlue => const Color(0xFFBFDDF0),
    PresetColorKey.cream => const Color(0xFFFFF8E8),
    PresetColorKey.cocoa => const Color(0xFF6D4638),
  };
}
