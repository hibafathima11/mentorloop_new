import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check if email exists
      final emailExists = await AuthService.emailExists(_emailController.text.trim());
      if (!emailExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this email address'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Send password reset email
      await AuthService.sendPasswordResetEmail(_emailController.text.trim());
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Please check your inbox.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email address';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many requests. Please try again later.';
      } else {
        errorMessage = e.message ?? 'Failed to send reset email';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Light coffee background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
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
              Text(
                "Forgot Password",
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 32,
                    tablet: 36,
                    desktop: 40,
                  ),
                  fontWeight: FontWeight.bold,
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
              Text(
                _emailSent
                    ? "Check your email for password reset instructions"
                    : "Enter your email address to reset your password",
                style: TextStyle(
                  color: _emailSent
                      ? Colors.green[700]
                      : const Color.fromARGB(255, 188, 118, 93),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    enabled: !_emailSent,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Your Email Address",
                      hintText: "student@example.com",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
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
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 30,
                  tablet: 40,
                  desktop: 50,
                ),
              ),
              // Send reset email button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _isLoading || _emailSent ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emailSent
                        ? Colors.green
                        : const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: ResponsiveHelper.getResponsiveIconSize(context),
                          width: ResponsiveHelper.getResponsiveIconSize(context),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _emailSent ? Icons.check_circle : Icons.send,
                              size: ResponsiveHelper.getResponsiveIconSize(context, mobile: 18, tablet: 20, desktop: 22),
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                            Text(
                              _emailSent ? "Email Sent!" : "Send Reset Email",
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 18,
                                  tablet: 20,
                                  desktop: 22,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_emailSent) ...[
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context),
                ),
                Container(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700], size: ResponsiveHelper.getResponsiveIconSize(context)),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                      Expanded(
                        child: Text(
                          'We\'ve sent password reset instructions to ${_emailController.text.trim()}. Please check your inbox and spam folder.',
                          style: TextStyle(
                            color: Colors.green[900],
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 40,
                  tablet: 50,
                  desktop: 60,
                ),
              ),
              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remember your password? ",
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Log in",
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
            ],
          ),
        ),
      ),
    );
  }
}
