import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/task_logo.dart';
import '../auth/login_screen.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.primary,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Organize your day.',
      subtitle: 'Keep your daily routine structured\nand tasks neatly organized.',
      icon: Icons.event_note_rounded,
      iconColor: Color(0xFF6B66FA),
    ),
    OnboardingItem(
      title: 'Track your progress.',
      subtitle: 'Prioritize what matters most with\nsmart tags and real-time updates.',
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFF7A79FB),
    ),
    OnboardingItem(
      title: 'Get things done.',
      subtitle: 'Just a click away from\nplanning your tasks.',
      icon: Icons.check_rounded,
      iconColor: AppColors.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final quarterCircleSize = size.width * 0.38 > 140.0 ? 140.0 : size.width * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Swipeable PageView with 3 dynamic onboarding screens
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final item = _pages[index];

              return SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(flex: 2),

                                // Logo Illustration with Sparkles
                                Center(
                                  child: TaskLogo(
                                    size: 96,
                                    icon: item.icon,
                                    backgroundColor: item.iconColor,
                                  ),
                                ),

                                const Spacer(flex: 3),

                                // Headline
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Subtitle
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Dynamic 3 Dot Indicators
                                Row(
                                  children: List.generate(_pages.length, (dotIndex) {
                                    final isActive = _currentPage == dotIndex;
                                    return GestureDetector(
                                      onTap: () {
                                        _pageController.animateToPage(
                                          dotIndex,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        margin: const EdgeInsets.only(right: 6),
                                        width: isActive ? 18 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.primary
                                              : const Color(0xFFD5D9E2),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                const Spacer(flex: 4),

                                // Bottom clearance for quarter-circle button
                                SizedBox(height: quarterCircleSize * 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Top Skip Button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Quarter Circle Action Button in bottom-right corner
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _onNext,
              child: Container(
                width: quarterCircleSize,
                height: quarterCircleSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7A79FB),
                      AppColors.primary,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(120),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 28, top: 28),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
