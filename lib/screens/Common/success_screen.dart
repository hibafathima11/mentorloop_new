import 'package:flutter/material.dart';

import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Light coffee background
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 100,
                    tablet: 120,
                    desktop: 140,
                  ),
                  height: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 100,
                    tablet: 120,
                    desktop: 140,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C), // Coffee brown
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveIconSize(
                        context,
                        mobile: 50,
                        tablet: 60,
                        desktop: 70,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5E3C).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 50,
                      tablet: 60,
                      desktop: 70,
                    ),
                    color: Colors.white,
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
                // Success title
                Text(
                  "Success!",
                  style: TextStyle(
                    color: const Color(0xFF8B5E3C), // Coffee brown
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
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
                // Success message
                Text(
                  "Your account has been successfully created. Welcome to MentorLoop!",
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
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.getResponsiveButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.pushReplacement(
                      // //   context,
                      // //   MaterialPageRoute(
                      // //     builder: (context) => const StudentDashboardScreen(),
                      // //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C), // Coffee brown
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                      ),
                    ),
                    child: Text(
                      "Continue to Dashboard",
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
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 20,
                    tablet: 25,
                    desktop: 30,
                  ),
                ),
                // Additional info
                Container(
                  width: double.infinity,
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        color: const Color(0xFF8B5E3C), // Coffee brown
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 15,
                          tablet: 20,
                          desktop: 25,
                        ),
                      ),
                      Text(
                        "What's Next?",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5E3C), // Coffee brown
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 15,
                          tablet: 20,
                          desktop: 25,
                        ),
                      ),
                      Text(
                        "• Complete your profile\n• Explore available courses\n• Connect with teachers\n• Start your learning journey",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
