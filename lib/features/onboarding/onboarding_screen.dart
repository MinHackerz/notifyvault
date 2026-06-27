import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';
import '../../app/router/app_router.dart';
import '../../providers/settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  late final _pages = [
    const _OnboardingPage(
      visual: _CaptureVisual(),
      title: 'Capture Every\nNotification',
      subtitle:
          'Automatically save notifications from all your apps. Never miss an OTP, delivery update, or important message again.',
    ),
    const _OnboardingPage(
      visual: _SearchVisual(),
      title: 'Search & Organize\nInstantly',
      subtitle:
          'Find any notification in milliseconds. Smart categories organize your OTPs, banking, shopping, and social updates automatically.',
    ),
    const _OnboardingPage(
      visual: _SecurityVisual(),
      title: 'Secure &\nPrivate',
      subtitle:
          'Your notifications stay on your device by default. Cloud backup is optional and fully encrypted. Your data, your rules.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(onboardingCompleteProvider.notifier).complete();
    context.go(AppRoutes.permission);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _pages[index],
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final Widget visual;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.visual,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Visual illustration
          visual,

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.normal,
              height: 1.2,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _CaptureVisual extends StatelessWidget {
  const _CaptureVisual();

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 190,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Notification 1
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildMockNotification(
              context: context,
              appName: 'WhatsApp',
              icon: HugeIcons.strokeRoundedBubbleChat,
              color: const Color(0xFF25D366),
              title: 'Alex',
              body: "Hey, did you see the update? 🚀",
            ),
          ),
          // Notification 2
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: _buildMockNotification(
              context: context,
              appName: 'DoorDash',
              icon: HugeIcons.strokeRoundedDeliveryTruck01,
              color: const Color(0xFFFF3008),
              title: 'Order Status',
              body: "Your order has been delivered! 🍕",
            ),
          ),
          // Notification 3
          Positioned(
            top: 130,
            left: 10,
            right: 10,
            child: _buildMockNotification(
              context: context,
              appName: 'Bank',
              icon: HugeIcons.strokeRoundedBank,
              color: const Color(0xFF007AFF),
              title: 'Alert',
              body: 'OTP: 482910 is valid for 10 minutes.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockNotification({
    required BuildContext context,
    required String appName,
    required List<List<dynamic>> icon,
    required Color color,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: HugeIcon(icon: icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Just now',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchVisual extends StatelessWidget {
  const _SearchVisual();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 180,
      width: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search OTP, messages...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(context, 'All', isSelected: true),
              _buildChip(context, 'OTPs', isSelected: false),
              _buildChip(context, 'Finance', isSelected: false),
            ],
          ),
          const SizedBox(height: 12),
          // Filtered notification
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedKey01,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Google Authentication',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your code is: 593 192',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {required bool isSelected}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _SecurityVisual extends StatelessWidget {
  const _SecurityVisual();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 160,
      width: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central Shield + Lock in clean flat style
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCircleUnlock01,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),

          // Badges
          Positioned(
            top: 10,
            left: 40,
            child: _buildOrbitingBadge(context, HugeIcons.strokeRoundedFileLock, 'Local DB'),
          ),
          Positioned(
            bottom: 10,
            right: 40,
            child: _buildOrbitingBadge(context, HugeIcons.strokeRoundedCloudUpload, 'Backup'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitingBadge(BuildContext context, List<List<dynamic>> icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
