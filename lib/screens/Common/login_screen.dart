import 'package:flutter/material.dart';
import 'package:mentorloop_new/screens/Common/signup_screen.dart';
import 'package:mentorloop_new/screens/Student/home_screen.dart';
import 'package:mentorloop_new/screens/Teacher/teacher_dashboard_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_dashboard_screen.dart';
import 'package:mentorloop_new/web/screens/admin_dashboard_screen.dart' as web_admin;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mentorloop_new/screens/Parent/parent_dashboard_screen.dart';
import 'package:mentorloop_new/screens/common/forgot_password_screen.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:mentorloop_new/utils/page_transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Handle hardcoded admin login without hitting Firebase
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();
      final isAdminEmail = email == 'admin@example.com' || email == 'admin';
      if (isAdminEmail && password == '123456') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin login successful')));
        final Widget destination = kIsWeb
            ? const web_admin.AdminDashboardScreen()
            : const AdminDashboardScreen();
        Navigator.of(context).pushReplacementSlide(
          destination,
          direction: SlideDirection.left,
        );
        return;
      }

      // Teacher invite fallback aware login
      final userCredential = await AuthService.loginWithTeacherInviteFallback(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Get user profile to check role and approval
      final userProfile = await AuthService.getUserProfile(
        userCredential.user!.uid,
      );

      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final role = userProfile['role'] as String?;
      final approved = userProfile['approved'] as bool? ?? false;

      // Check if student/parent is approved
      if ((role == 'student' || role == 'parent') && !approved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account is pending admin approval. Please wait.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Navigate based on role
      Widget destination;
      switch (role) {
        case 'student':
          destination = const StudentHomeScreen();
          break;
        case 'teacher':
          destination = const TeacherDashboardScreen();
          break;
        case 'parent':
          destination = const ParentDashboardScreen();
          break;
        default:
          throw Exception('Invalid user role');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    try {
      final profile = await AuthService.signInWithGoogleAndEnsureProfile();
      final String role = (profile['role'] as String?) ?? 'student';
      final bool approved = (profile['approved'] as bool?) ?? false;

      if ((role == 'student' || role == 'parent') && !approved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account is pending admin approval. Please wait.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Widget destination;
      switch (role) {
        case 'student':
          destination = const StudentHomeScreen();
          break;
        case 'teacher':
          destination = const TeacherDashboardScreen();
          break;
        case 'parent':
          destination = const ParentDashboardScreen();
          break;
        default:
          destination = const StudentHomeScreen();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldBg, // themed background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),
                // Header
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: primary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 32,
                          tablet: 36,
                          desktop: 40,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                // Email field
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Your Email",
                          hintText: "Cooper_Kristin@gmail.com",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding:
                              ResponsiveHelper.getResponsivePaddingSymmetric(
                                context,
                                horizontal: 20,
                                vertical: 16,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Password field
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding:
                              ResponsiveHelper.getResponsivePaddingSymmetric(
                                context,
                                horizontal: 20,
                                vertical: 16,
                              ),
                          suffixIcon: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                  context,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 10,
                    tablet: 15,
                    desktop: 20,
                  ),
                ),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushSlide(
                        const ForgotPasswordScreen(),
                        direction: SlideDirection.right,
                      );
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ), // Darker coffee
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
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
                // Login button
                FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: SizedBox(
                      width: double.infinity,
                      height: ResponsiveHelper.getResponsiveButtonHeight(
                        context,
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 18,
                                        tablet: 20,
                                        desktop: 22,
                                      ),
                                  fontWeight: FontWeight.w600,
                                ),
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
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ), // Darker coffee
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushSlide(
                          const SignupScreen(),
                          direction: SlideDirection.right,
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: const Color(0xFF8B5E3C), // Coffee brown
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 40,
                    tablet: 50,
                    desktop: 60,
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ).withOpacity(0.3), // Darker coffee with opacity
                      ),
                    ),
                    Padding(
                      padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                        context,
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: Text(
                        "Or log in with",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 188, 118, 93),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color.fromARGB(
                          255,
                          188,
                          118,
                          93,
                        ).withOpacity(0.3), // Darker coffee with opacity
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 30,
                    tablet: 40,
                    desktop: 50,
                  ),
                ),
                // Social login buttons
                FadeTransition(
                  opacity: _fadeIn,
                  child: ResponsiveHelper.responsiveBuilder(
                    context: context,
                    mobile: Column(children: [_buildGoogleButton(context)]),
                    tablet: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: _buildGoogleButton(context)),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveMargin(
                            context,
                            mobile: 20,
                            tablet: 25,
                            desktop: 30,
                          ),
                        ),
                      ],
                    ),
                    desktop: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.screenWidth(context) * 0.2,
                          child: _buildGoogleButton(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    IconData icon,
    Color color,
    String text,
  ) {
    return Container(
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveCardRadius(context),
        ),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveMargin(
              context,
              mobile: 10,
              tablet: 15,
              desktop: 20,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return InkWell(
      onTap: _isGoogleLoading ? null : _handleGoogleLogin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildSocialButton(context, Icons.g_mobiledata, Colors.red, "Google"),
          if (_isGoogleLoading)
            Positioned(
              right: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
