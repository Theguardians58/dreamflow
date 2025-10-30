import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_bloom/theme.dart';
import 'package:aura_bloom/screens/splash_screen.dart';
import 'package:aura_bloom/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura - Style Companion',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
