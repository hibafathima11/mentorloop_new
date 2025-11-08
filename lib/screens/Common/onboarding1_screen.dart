import 'package:flutter/material.dart';
import 'package:mentorloop/screens/common/onboarding2_screen.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/colors.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Light coffee background
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding2Screen(),
                      ),
                    );
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: const Color.fromARGB(
                        255,
                        188,
                        118,
                        93,
                      ), // Darker coffee
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
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 60,
                  tablet: 80,
                  desktop: 100,
                ),
              ),
              // Main illustration without container
              Expanded(
                child: Image.asset("assets/man.png", fit: BoxFit.contain),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 40,
                  tablet: 50,
                  desktop: 60,
                ),
              ),
              // Text content
              Text(
                "Quick and easy learning",
                style: TextStyle(
                  color: const Color(0xFF8B5E3C), // Coffee brown
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
              Text(
                "Access study materials, videos, and interactive content anytime, anywhere",
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
                      color: const Color(0xFF8B5E3C), // Coffee brown
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
                      color: const Color(
                        0xFF8B5E3C,
                      ).withOpacity(0.3), // Coffee brown with opacity
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
                      color: const Color(
                        0xFF8B5E3C,
                      ).withOpacity(0.3), // Coffee brown with opacity
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
              // Next button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding2Screen(),
                      ),
                    );
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
                    "Next",
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
            ],
          ),
        ),
      ),
    );
  }
}
