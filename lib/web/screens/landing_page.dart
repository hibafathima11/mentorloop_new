import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/screens/admin_login_screen.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Navbar
            _buildNavbar(context, isMobile, isTablet),
            // Hero Section
            _buildHeroSection(context, isMobile, isTablet),
            // Features Section
            _buildFeaturesSection(context, isMobile, isTablet),
            // Stats Section
            _buildStatsSection(context, isMobile, isTablet),
            // CTA Section
            _buildCtaSection(context, isMobile, isTablet),
            // Footer
            _buildFooter(context, isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      height: ResponsiveHelper.getResponsiveButtonHeight(context, mobile: 60, tablet: 70, desktop: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveHelper.getResponsivePaddingSymmetric(
          context,
          horizontal: isMobile ? 16 : (isTablet ? 30 : 40),
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getResponsiveIconSize(context),
                      height: ResponsiveHelper.getResponsiveIconSize(context),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5E3C).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'ML',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
                    if (!isMobile)
                      Text(
                        'MentorLoop',
                        style: TextStyle(
                          color: const Color(0xFF8B5E3C),
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Nav Links
            if (!isMobile)
              Row(
                children: [
                  _navLink('Features', context, () {
                    _scrollToSection(1);
                  }),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                  _navLink('About', context, () {
                    _scrollToSection(2);
                  }),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                  _navLink('Contact', context, () {
                    _scrollToSection(3);
                  }),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                  ElevatedButton(
                    onPressed: () => _navigateToAdminLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
                        vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                      ),
                    ),
                    child: Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => _navigateToAdminLogin(context),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(int sectionIndex) {
    // Simple scroll to approximate positions
    final positions = [0.0, 400.0, 1200.0, 2000.0];
    if (sectionIndex < positions.length) {
      _scrollController.animateTo(
        positions[sectionIndex],
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _navLink(String text, BuildContext context, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5E3C).withOpacity(0.1),
            const Color(0xFF8B5E3C).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Empower Learning, Inspire Growth',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 36,
                desktop: 48,
              ),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
          Text(
            'An intelligent platform connecting teachers, students, and parents\nto create meaningful educational experiences',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              height: 1.6,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 32, tablet: 40, desktop: 48)),
          if (isMobile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAdminLogin(context),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Admin Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveSpacing(context),
                        vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Download Mobile App'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveSpacing(context),
                        vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToAdminLogin(context),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: Text(
                    'Go to Admin Dashboard',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 24, tablet: 28, desktop: 32),
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 14, tablet: 15, desktop: 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context)),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new),
                  label: Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveSpacing(context, mobile: 24, tablet: 28, desktop: 32),
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, mobile: 14, tablet: 15, desktop: 16),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isMobile, bool isTablet) {
    final stats = [
      {'value': '10K+', 'label': 'Active Students'},
      {'value': '500+', 'label': 'Teachers'},
      {'value': '1K+', 'label': 'Courses'},
      {'value': '50K+', 'label': 'Assignments'},
    ];

    return Container(
      padding: ResponsiveHelper.getResponsivePaddingAll(context, mobile: 40, tablet: 60, desktop: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5E3C).withOpacity(0.05),
            const Color(0xFF6B4423).withOpacity(0.05),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isMobile(context)) {
            return Column(
              children: stats.map((stat) => Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveHelper.getResponsiveSpacing(context),
                ),
                child: _statCard(stat['value']!, stat['label']!, context),
              )).toList(),
            );
          } else if (ResponsiveHelper.isTablet(context)) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 2,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _statCard(stats[index]['value']!, stats[index]['label']!, context),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((stat) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _statCard(stat['value']!, stat['label']!, context),
                ),
              )).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _statCard(String value, String label, BuildContext context) {
    return Container(
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, mobile: 28, tablet: 32, desktop: 36),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B5E3C),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isMobile, bool isTablet) {
    final features = [
      {
        'icon': Icons.school,
        'title': 'For Teachers',
        'desc': 'Create courses, upload videos, manage assignments, and track student progress',
      },
      {
        'icon': Icons.person,
        'title': 'For Students',
        'desc': 'Learn at your own pace, submit assignments, and engage with course content',
      },
      {
        'icon': Icons.family_restroom,
        'title': 'For Parents',
        'desc': 'Monitor your child\'s progress and communicate with teachers',
      },
      {
        'icon': Icons.dashboard,
        'title': 'Admin Control',
        'desc': 'Manage all users, courses, and platform analytics from one dashboard',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            'Platform Features',
            style: TextStyle(
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 32 : 40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything you need for modern education management',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.2,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _featureCard(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                desc: feature['desc'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5E3C),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 60,
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5E3C),
            const Color(0xFF6B4628),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Transform Education?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 24 : 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Join thousands of educators and learners using MentorLoop',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _navigateToAdminLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5E3C),
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Get Started with Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '© 2025 MentorLoop. All rights reserved.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Row(
                  children: [
                    _footerLink('Privacy Policy'),
                    const SizedBox(width: 24),
                    _footerLink('Terms of Service'),
                    const SizedBox(width: 24),
                    _footerLink('Contact'),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                _footerLink('Privacy Policy'),
                const SizedBox(height: 12),
                _footerLink('Terms of Service'),
                const SizedBox(height: 12),
                _footerLink('Contact'),
                const SizedBox(height: 24),
                const Text(
                  '© 2025 MentorLoop. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8B5E3C),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAdminLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminLoginScreen(),
      ),
    );
  }
}
