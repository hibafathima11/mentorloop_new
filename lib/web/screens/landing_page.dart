import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/screens/admin_login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navbar
            _buildNavbar(context, isMobile),
            // Hero Section
            _buildHeroSection(context, isMobile),
            // Features Section
            _buildFeaturesSection(context, isMobile),
            // CTA Section
            _buildCtaSection(context, isMobile),
            // Footer
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isMobile) {
    return Container(
      height: 70,
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C),
                    borderRadius: BorderRadius.circular(8),
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
                const SizedBox(width: 12),
                if (!isMobile)
                  const Text(
                    'MentorLoop',
                    style: TextStyle(
                      color: Color(0xFF8B5E3C),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
              ],
            ),
            // Nav Links
            if (!isMobile)
              Row(
                children: [
                  _navLink('Features', context),
                  const SizedBox(width: 32),
                  _navLink('About', context),
                  const SizedBox(width: 32),
                  _navLink('Contact', context),
                  const SizedBox(width: 32),
                  ElevatedButton(
                    onPressed: () => _navigateToAdminLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Admin Login'),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => _navigateToAdminLogin(context),
                icon: const Icon(Icons.login),
                label: const Text('Admin'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String text, BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
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
        children: [
          Text(
            'Empower Learning, Inspire Growth',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8B5E3C),
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 28 : 48,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'An intelligent platform connecting teachers, students, and parents\nto create meaningful educational experiences',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 14 : 18,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          if (isMobile)
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _navigateToAdminLogin(context),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Download Mobile App'),
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
                  label: const Text('Go to Admin Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Learn More'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isMobile) {
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

  Widget _buildCtaSection(BuildContext context, bool isMobile) {
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

  Widget _buildFooter(BuildContext context, bool isMobile) {
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8B5E3C),
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
