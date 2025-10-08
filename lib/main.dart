import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SpookyApp());
}

class SpookyApp extends StatelessWidget {
  const SpookyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF6A00), // pumpkin orange
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Spooky Storybook',
      theme: ThemeData(
        colorScheme: colorScheme,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F1A),
        textTheme: GoogleFonts.cinzelTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/game': (_) => const GameScreen(),
      },
    );
  }
}

