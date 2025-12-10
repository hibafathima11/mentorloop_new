import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/screens/admin_login_screen.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5E3C).withValues(alpha: 0.03 + _pulseController.value * 0.02),
                      const Color(0xFF6B4423).withValues(alpha: 0.02 + _pulseController.value * 0.01),
                      Colors.white,
                    ],
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      height: ResponsiveHelper.getResponsiveButtonHeight(
        context,
        mobile: 70,
        tablet: 80,
        desktop: 90,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveHelper.getResponsivePaddingSymmetric(
          context,
          horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo with animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveHelper.getResponsiveIconSize(context) + 4,
                        height: ResponsiveHelper.getResponsiveIconSize(context) + 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5E3C).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ML',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),
                      if (!isMobile)
                        Text(
                          'MentorLoop',
                          style: TextStyle(
                            color: const Color(0xFF8B5E3C),
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 20,
                              tablet: 24,
                              desktop: 28,
                            ),
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Nav Links
            if (!isMobile)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    _navLink('Features', context, () {
                      _scrollToSection(1);
                    }),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveSpacing(context),
                    ),
                    _navLink('About', context, () {
                      _scrollToSection(2);
                    }),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveSpacing(context),
                    ),
                    _navLink('Contact', context, () {
                      _scrollToSection(3);
                    }),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveSpacing(context),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5E3C).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _navigateToAdminLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 20,
                              tablet: 24,
                              desktop: 28,
                            ),
                            vertical: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize:
                                ResponsiveHelper.getResponsiveFontSize(context),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _navigateToAdminLogin(context),
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _scrollToSection(int sectionIndex) {
    final positions = [0.0, 500.0, 1400.0, 2200.0];
    if (sectionIndex < positions.length) {
      _scrollController.animateTo(
        positions[sectionIndex],
        duration: const Duration(milliseconds: 800),
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
        hoverColor: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 120,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B4423).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF8B5E3C).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: const Color(0xFF8B5E3C),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Trusted by 10,000+ Educators',
                              style: TextStyle(
                                color: const Color(0xFF8B5E3C),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 32,
                          tablet: 40,
                          desktop: 48,
                        ),
                      ),
                      // Main heading with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                        ).createShader(bounds),
                        child: Text(
                          'Empower Learning,\nInspire Growth',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 36,
                              tablet: 48,
                              desktop: 64,
                            ),
                            letterSpacing: -1,
                            height: 1.1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(context),
                      ),
                      Text(
                        'An intelligent platform connecting teachers, students, and parents\nto create meaningful educational experiences',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          mobile: 40,
                          tablet: 48,
                          desktop: 56,
                        ),
                      ),
                      // CTA Buttons
                      if (isMobile)
                        Column(
                          children: [
                            _buildGradientButton(
                              context,
                              'Go to Admin Dashboard',
                              Icons.admin_panel_settings,
                              () => _navigateToAdminLogin(context),
                              isPrimary: true,
                            ),
                            const SizedBox(height: 16),
                            _buildGradientButton(
                              context,
                              'Download Mobile App',
                              Icons.download,
                              () {},
                              isPrimary: false,
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGradientButton(
                              context,
                              'Go to Admin Dashboard',
                              Icons.admin_panel_settings,
                              () => _navigateToAdminLogin(context),
                              isPrimary: true,
                            ),
                            const SizedBox(width: 20),
                            _buildGradientButton(
                              context,
                              'Learn More',
                              Icons.arrow_forward,
                              () {},
                              isPrimary: false,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5E3C).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 28,
                tablet: 32,
                desktop: 36,
              ),
              vertical: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B5E3C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 28,
              tablet: 32,
              desktop: 36,
            ),
            vertical: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          side: const BorderSide(color: Color(0xFF8B5E3C), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  Widget _buildStatsSection(BuildContext context, bool isMobile, bool isTablet) {
    final stats = <Map<String, dynamic>>[
      {'value': '10K+', 'label': 'Active Students', 'icon': Icons.people},
      {'value': '500+', 'label': 'Teachers', 'icon': Icons.school},
      {'value': '1K+', 'label': 'Courses', 'icon': Icons.book},
      {'value': '50K+', 'label': 'Assignments', 'icon': Icons.assignment},
    ];

    return Container(
      padding: ResponsiveHelper.getResponsivePaddingAll(
        context,
        mobile: 60,
        tablet: 80,
        desktop: 100,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isMobile(context)) {
            return Column(
              children: stats
                  .map((stat) => Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveHelper.getResponsiveSpacing(context),
                        ),
                        child: _statCard(
                          stat['value'] as String,
                          stat['label'] as String,
                          stat['icon'] as IconData,
                          context,
                        ),
                      ))
                  .toList(),
            );
          } else if (ResponsiveHelper.isTablet(context)) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.5,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _statCard(
                stats[index]['value'] as String,
                stats[index]['label'] as String,
                stats[index]['icon'] as IconData,
                context,
              ),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _statCard(
                            stat['value'] as String,
                            stat['label'] as String,
                            stat['icon'] as IconData,
                            context,
                          ),
                        ),
                      ))
                  .toList(),
            );
          }
        },
      ),
    );
  }

  Widget _statCard(
    String value,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: ResponsiveHelper.getResponsivePaddingAll(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                    const Color(0xFF6B4423).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8B5E3C),
                size: 32,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
              ).createShader(bounds),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 32,
                    tablet: 36,
                    desktop: 42,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveSpacing(
                context,
                mobile: 6,
                tablet: 8,
                desktop: 10,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    final features = [
      {
        'icon': Icons.school,
        'title': 'For Teachers',
        'desc':
            'Create engaging courses, upload video content, manage assignments, conduct exams, and track student progress with powerful analytics. Build interactive learning experiences that inspire and educate.',
        'color': const Color(0xFF8B5E3C),
      },
      {
        'icon': Icons.person,
        'title': 'For Students',
        'desc':
            'Learn at your own pace with flexible course access, submit assignments seamlessly, engage with interactive content, take exams, and track your academic progress in real-time.',
        'color': const Color(0xFF6B9D5C),
      },
      {
        'icon': Icons.family_restroom,
        'title': 'For Parents',
        'desc':
            'Monitor your child\'s academic progress, view assignment submissions, communicate directly with teachers, and stay informed about their educational journey and achievements.',
        'color': const Color(0xFF5B7DB9),
      },
      {
        'icon': Icons.dashboard,
        'title': 'Admin Control',
        'desc':
            'Manage all users, courses, assignments, and exams from one comprehensive dashboard. Access detailed analytics, approve student registrations, and maintain complete platform oversight.',
        'color': const Color(0xFFC75D3A),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 80,
      ),
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  'Platform Features',
                  style: TextStyle(
                    color: const Color(0xFF8B5E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 36,
                      tablet: 44,
                      desktop: 52,
                    ),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Everything you need for modern education management',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isMobile ? 1.2 : 1.3,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: _featureCard(
                        icon: feature['icon'] as IconData,
                        title: feature['title'] as String,
                        desc: feature['desc'] as String,
                        color: feature['color'] as Color,
                      ),
                    ),
                  );
                },
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
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                desc,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.6,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 80,
      ),
      padding: EdgeInsets.all(isMobile ? 32 : 64),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5E3C).withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Transform Education?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 36,
                desktop: 44,
              ),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of educators and learners using MentorLoop',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _navigateToAdminLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF8B5E3C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Get Started with Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 40,
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
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'ML',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '© 2025 MentorLoop. All rights reserved.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'ML',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
