import 'package:flutter/material.dart';
import 'package:mentorloop/screens/common/login_screen.dart';
import 'package:mentorloop/screens/common/signup_screen.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/colors.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Light coffee background
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Center(
                child: Image.asset(
                  "assets/lady.png",
                  height: ResponsiveHelper.screenHeight(context) * 0.4,
                  fit: BoxFit.contain,
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
              // Title
              Text(
                "Track your progress",
                style: TextStyle(
                  color: AppColors.textPrimary, // Coffee brown
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 20,
                  tablet: 25,
                  desktop: 30,
                ),
              ),
              // Description
              Text(
                "Monitor performance, attendance, and learning analytics in real-time",
                style: TextStyle(
                  color: AppColors.textSecondary, // Darker coffee
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 40,
                  tablet: 50,
                  desktop: 60,
                ),
              ),
              // Navigation dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withOpacity(
                        0.3,
                      ), // Coffee brown with opacity
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 6,
                          tablet: 7,
                          desktop: 8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  Container(
                    width: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton, // Coffee brown
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 6,
                          tablet: 7,
                          desktop: 8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                  Container(
                    width: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton.withOpacity(
                        0.3,
                      ), // Coffee brown with opacity
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 6,
                          tablet: 7,
                          desktop: 8,
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
              // Buttons
              ResponsiveHelper.responsiveBuilder(
                context: context,
                mobile: Column(
                  children: [
                    _buildSignUpButton(context),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 20,
                        tablet: 25,
                        desktop: 30,
                      ),
                    ),
                    _buildLoginButton(context),
                  ],
                ),
                tablet: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _buildSignUpButton(context)),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 20,
                        tablet: 25,
                        desktop: 30,
                      ),
                    ),
                    Expanded(child: _buildLoginButton(context)),
                  ],
                ),
                desktop: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ResponsiveHelper.screenWidth(context) * 0.3,
                      child: _buildSignUpButton(context),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 20,
                        tablet: 25,
                        desktop: 30,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.screenWidth(context) * 0.3,
                      child: _buildLoginButton(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton, // Coffee brown
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveCardRadius(context),
            ),
          ),
        ),
        child: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.getResponsiveButtonHeight(context),
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryButton, // Coffee brown
          side: BorderSide(
            color: AppColors.primaryButton,
          ), // Coffee brown border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveCardRadius(context),
            ),
          ),
        ),
        child: Text(
          "Log In",
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
