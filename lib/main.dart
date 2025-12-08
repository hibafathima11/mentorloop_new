import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mentorloop_new/screens/common/splash_screen.dart';
import 'package:mentorloop_new/web/screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5E3C)),
      useMaterial3: true,
      fontFamily: 'Poppins',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MentorLoop',
      theme: base.copyWith(
        splashFactory: InkRipple.splashFactory,
        scaffoldBackgroundColor: const Color(0xFFF5EDE3),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF8B5E3C),
          centerTitle: false,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF8B5E3C),
          contentTextStyle: const TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(const Color(0xFF8B5E3C)),
            foregroundColor: const MaterialStatePropertyAll(Colors.white),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.white.withOpacity(0.08);
              }
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.06);
              }
              if (states.contains(MaterialState.focused)) {
                return Colors.white.withOpacity(0.04);
              }
              return null;
            }),
            splashFactory: InkRipple.splashFactory,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const MaterialStatePropertyAll(Color(0xFF8B5E3C)),
            side: const MaterialStatePropertyAll(
              BorderSide(color: Color(0xFF8B5E3C), width: 1.5),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF8B5E3C).withOpacity(0.08);
              }
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF8B5E3C).withOpacity(0.06);
              }
              if (states.contains(MaterialState.focused)) {
                return const Color(0xFF8B5E3C).withOpacity(0.04);
              }
              return null;
            }),
            splashFactory: InkRipple.splashFactory,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const MaterialStatePropertyAll(Color(0xFF8B5E3C)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color(0xFF8B5E3C).withOpacity(0.1);
              }
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF8B5E3C).withOpacity(0.08);
              }
              if (states.contains(MaterialState.focused)) {
                return const Color(0xFF8B5E3C).withOpacity(0.06);
              }
              return null;
            }),
            splashFactory: InkRipple.splashFactory,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.08),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: kIsWeb ? const LandingPage() : const SplashScreen(),
    );
  }
}
