import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  static double getResponsiveFontSize(BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets getResponsivePaddingAll(BuildContext context, {
    double mobile = 20,
    double tablet = 30,
    double desktop = 40,
  }) {
    double padding = isMobile(context) ? mobile : (isTablet(context) ? tablet : desktop);
    return EdgeInsets.all(padding);
  }

  static EdgeInsets getResponsivePaddingSymmetric(BuildContext context, {
    double horizontal = 20,
    double vertical = 20,
  }) {
    double hPadding = isMobile(context) 
        ? horizontal 
        : (isTablet(context) ? horizontal * 1.5 : horizontal * 2);
    double vPadding = isMobile(context) 
        ? vertical 
        : (isTablet(context) ? vertical * 1.5 : vertical * 2);
    return EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding);
  }

  static double getResponsiveSpacing(BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsiveMargin(BuildContext context, {
    double mobile = 20,
    double tablet = 25,
    double desktop = 30,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsiveIconSize(BuildContext context, {
    double mobile = 24,
    double tablet = 28,
    double desktop = 32,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsiveButtonHeight(BuildContext context, {
    double mobile = 50,
    double tablet = 55,
    double desktop = 60,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsiveCardRadius(BuildContext context, {
    double mobile = 12,
    double tablet = 15,
    double desktop = 18,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int crossAxisCount = 2,
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 10,
    double mainAxisSpacing = 10,
  }) {
    // Make grid responsive based on screen size
    int responsiveCrossAxisCount = crossAxisCount;
    if (isMobile(context)) {
      responsiveCrossAxisCount = 1;
    } else if (isTablet(context)) {
      responsiveCrossAxisCount = crossAxisCount.clamp(1, 2);
    } else {
      responsiveCrossAxisCount = crossAxisCount.clamp(2, 4);
    }
    
    return GridView.count(
      crossAxisCount: responsiveCrossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      children: children,
    );
  }

  static int getResponsiveCrossAxisCount(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}
