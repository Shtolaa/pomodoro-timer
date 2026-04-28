import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
