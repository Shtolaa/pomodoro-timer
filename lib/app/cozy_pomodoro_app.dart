import 'package:flutter/material.dart';

import '../features/app_theme/domain/pomodoro_theme.dart';
import '../features/timer/presentation/home_screen.dart';

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
