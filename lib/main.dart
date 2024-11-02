import 'package:cards/screens/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards',
      theme: ThemeData(
        brightness: Brightness.dark, // Set overall brightness to dark
        scaffoldBackgroundColor: Colors.green[900], // Dark green background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white), // Default text color
          bodyLarge: TextStyle(color: Colors.white),
          // ... other text styles you want to customize ...
          displayLarge: TextStyle(color: Colors.white), // For AppBar titles
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        hintColor: Colors.white70, // Hint text color in TextFields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(100), // Light gray background
          hintStyle: TextStyle(color: Colors.white70), // Hint text color
          labelStyle: TextStyle(color: Colors.white), // Label text color
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.green.withAlpha(100), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 4.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700], // Button background color
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ), // Button padding
            textStyle: const TextStyle(fontSize: 16), // Text style
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Button border radius
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[900], // Dark green AppBar
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          iconTheme:
              const IconThemeData(color: Colors.white), // White app bar icons
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        primaryIconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const StartScreen(),
    );
  }
}

Future<void> signInAnonymously() async {
  await FirebaseAuth.instance.signInAnonymously();
}
