import 'package:flutter/material.dart';
import 'package:mentorloop_new/screens/Common/onboarding1_screen.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/screens/Common/login_screen.dart';
import 'package:mentorloop_new/screens/Student/home_screen.dart';
import 'package:mentorloop_new/screens/Teacher/teacher_dashboard_screen.dart';
import 'package:mentorloop_new/screens/Parent/parent_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleIn = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _routeFromSplash();
  }

  Future<void> _routeFromSplash() async {
    // Give the splash a brief moment for UX consistency
    await Future.delayed(const Duration(milliseconds: 900));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _navigate(const Onboarding1Screen());
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();
      if (data == null) {
        // Missing profile; sign out and go to login
        await FirebaseAuth.instance.signOut();
        _navigate(const LoginScreen());
        return;
      }

      final String role = (data['role'] as String?) ?? '';
      final bool isApproved = (data['approved'] as bool?) ?? false;

      if (role == 'student' && !isApproved) {
        // Pending approval; sign out to block access until approved
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account is pending admin approval.'),
            backgroundColor: Colors.orange,
          ),
        );
        _navigate(const LoginScreen());
        return;
      }

      switch (role) {
        case 'student':
          _navigate(const StudentHomeScreen());
          break;
        case 'teacher':
          _navigate(const TeacherDashboardScreen());
          break;
        case 'parent':
          _navigate(const ParentDashboardScreen());
          break;
        default:
          // Unknown role; fallback to login
          await FirebaseAuth.instance.signOut();
          _navigate(const LoginScreen());
      }
    } catch (_) {
      // On any error, send to onboarding to keep app usable
      _navigate(const Onboarding1Screen());
    }
  }

  void _navigate(Widget destination) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOut));

          final scaleTween = Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOutCubic));

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryBackground,
              AppColors.secondaryBackground.withOpacity(0.95),
              const Color(0xFFF5EDE3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo image with shadow
                    FadeTransition(
                      opacity: _fadeIn,
                      child: ScaleTransition(
                        scale: _scaleIn,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(
                                    context,
                                  ) *
                                  2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5E3C).withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(
                                    context,
                                  ) *
                                  2,
                            ),
                            child: Image.asset(
                              'assets/splash.png',
                              height: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobile: 100,
                                tablet: 140,
                                desktop: 180,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 30,
                        tablet: 40,
                        desktop: 50,
                      ),
                    ),
                    // App name with shadow
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Text(
                        "MentorLoop",
                        style: TextStyle(
                          color: const Color(0xFF8B5E3C),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 36,
                            tablet: 44,
                            desktop: 52,
                          ),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF8B5E3C).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 12,
                        tablet: 18,
                        desktop: 24,
                      ),
                    ),
                    // Tagline
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Text(
                        "AI-Enhanced Academic Management",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 188, 118, 93),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 40,
                        tablet: 50,
                        desktop: 60,
                      ),
                    ),
                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeIn,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF8B5E3C),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
