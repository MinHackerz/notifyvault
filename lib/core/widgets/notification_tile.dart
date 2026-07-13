import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/notification_model.dart';
import '../../models/category_model.dart';
import '../extensions/date_extensions.dart';
import '../extensions/string_extensions.dart';
import 'category_chip.dart';
import '../../app/theme/app_colors.dart';

/// A premium flat notification list item with prominent app source display.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDismiss;
  final bool enableDismiss;
  final bool isPriority;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onFavoriteToggle,
    this.onDismiss,
    this.enableDismiss = true,
    this.isPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = CategoryModel.findById(notification.category);
    final isDark = theme.brightness == Brightness.dark;

    final cardWidget = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A2D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPriority
              ? Colors.amber.withValues(alpha: 0.5)
              : notification.isRead
                  ? (isDark ? AppColors.outlineDark : AppColors.outlineLight)
                  : theme.colorScheme.primary.withValues(alpha: 0.8),
          width: isPriority ? 1.5 : (notification.isRead ? 1.0 : 1.5),
        ),
        boxShadow: isDark
            ? [
                if (!notification.isRead)
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                if (isPriority)
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (!notification.isRead)
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.04),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                if (isPriority)
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.06),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App initials avatar in a clean flat box
                _buildAvatar(theme, category, isDark),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App name + time row
                      Row(
                        children: [
                          // Priority badge
                          if (isPriority) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded,
                                      size: 10, color: Colors.amber),
                                  SizedBox(width: 2),
                                  Text(
                                    'PRIORITY',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.amber,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate(
                                    onPlay: (c) => c.repeat(reverse: true))
                                .shimmer(
                                  duration: 2000.ms,
                                  color: Colors.amber.withValues(alpha: 0.3),
                                ),
                            const SizedBox(width: 6),
                          ],
                          // App source indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: category.color.withValues(alpha: 0.2),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: _getAppIcon(notification.packageName),
                                  size: 11,
                                  color: category.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.appName,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: category.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Unread dot (flat)
                          if (!notification.isRead) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            notification.timestamp.relativeTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      if (notification.title != null &&
                          notification.title!.isNotEmpty)
                        Text(
                          notification.title!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      // Body preview
                      if (notification.displayText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          notification.displayText.truncate(120),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Category chip + favorite
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CategoryChip(
                            category: category,
                            isSmall: true,
                          ),
                          if (notification.senderName != null) ...[
                            const SizedBox(width: 8),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedUser,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                notification.senderName!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (notification.isFavorite)
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 14,
                              color: Colors.amber,
                            ),
                        ],
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

    // Wrap in Dismissible only if enabled
    final wrappedWidget = enableDismiss
        ? Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => onDismiss?.call(),
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: theme.colorScheme.error,
                size: 20,
              ),
            ),
            child: cardWidget,
          )
        : cardWidget;

    return wrappedWidget
        .animate()
        .fadeIn(duration: 250.ms, curve: Curves.easeOutQuad)
        .slideY(begin: 0.08, end: 0, duration: 250.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildAvatar(ThemeData theme, CategoryModel category, bool isDark) {
    String? path = notification.iconPath;
    if (path == null || path.isEmpty) {
      path = '/data/user/0/com.notifyvault.app/files/icons/${notification.packageName}.png';
    }

    final file = File(path);
    if (file.existsSync()) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.file(
            file,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackAvatar(theme, category),
          ),
        ),
      );
    }
    return _buildFallbackAvatar(theme, category);
  }

  Widget _buildFallbackAvatar(ThemeData theme, CategoryModel category) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: category.color.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Center(
        child: HugeIcon(
          icon: _getAppIcon(notification.packageName),
          size: 22,
          color: category.color,
        ),
      ),
    );
  }

  /// Map package names to HugeIcons constants.
  List<List<dynamic>> _getAppIcon(String packageName) {
    final pkg = packageName.toLowerCase();
    if (pkg.contains('whatsapp')) return HugeIcons.strokeRoundedBubbleChat;
    if (pkg.contains('telegram')) return HugeIcons.strokeRoundedTelegram;
    if (pkg.contains('instagram')) return HugeIcons.strokeRoundedInstagram;
    if (pkg.contains('twitter') || pkg.contains('x.android')) return HugeIcons.strokeRoundedTwitter;
    if (pkg.contains('facebook')) return HugeIcons.strokeRoundedFacebook01;
    if (pkg.contains('youtube')) return HugeIcons.strokeRoundedYoutube;
    if (pkg.contains('gmail') || pkg.contains('mail')) return HugeIcons.strokeRoundedMail01;
    if (pkg.contains('chrome') || pkg.contains('browser')) return HugeIcons.strokeRoundedBrowser;
    if (pkg.contains('phone') || pkg.contains('dialer')) return HugeIcons.strokeRoundedSmartPhone01;
    if (pkg.contains('sms') || pkg.contains('messaging') || pkg.contains('messages')) return HugeIcons.strokeRoundedMessage01;
    if (pkg.contains('calendar')) return HugeIcons.strokeRoundedCalendar01;
    if (pkg.contains('maps') || pkg.contains('uber') || pkg.contains('ola')) return HugeIcons.strokeRoundedLocation01;
    if (pkg.contains('pay') || pkg.contains('gpay') || pkg.contains('phonepe') || pkg.contains('paytm')) return HugeIcons.strokeRoundedCreditCard;
    if (pkg.contains('bank') || pkg.contains('hdfc') || pkg.contains('icici') || pkg.contains('sbi')) return HugeIcons.strokeRoundedBank;
    if (pkg.contains('amazon') || pkg.contains('flipkart') || pkg.contains('myntra')) return HugeIcons.strokeRoundedShoppingBag01;
    if (pkg.contains('zomato') || pkg.contains('swiggy') || pkg.contains('doordash')) return HugeIcons.strokeRoundedDeliveryTruck01;
    if (pkg.contains('spotify') || pkg.contains('music')) return HugeIcons.strokeRoundedMusicNote01;
    if (pkg.contains('netflix') || pkg.contains('hotstar') || pkg.contains('prime')) return HugeIcons.strokeRoundedFilm01;
    return HugeIcons.strokeRoundedNotification01;
  }
}
