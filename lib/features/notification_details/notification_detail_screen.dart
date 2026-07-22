import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/notification_providers.dart';
import '../../models/notification_model.dart';
import '../../models/category_model.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/helpers/notification_parser.dart';
import '../../core/helpers/launch_app_helper.dart';
import '../../core/widgets/category_chip.dart';
import '../../app/theme/app_colors.dart';

import '../../core/widgets/fading_app_bar.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(notificationDetailProvider(notificationId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadingScaffold(
      title: const Text('Notification Details'),
        actions: [
          detailAsync.whenOrNull(
                data: (notification) {
                  if (notification == null) return const SizedBox.shrink();
                  return PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handleAction(context, ref, value, notification),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            width: 1.0,
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                HugeIcon(icon: HugeIcons.strokeRoundedCopy, size: 18, color: theme.colorScheme.onSurface),
                                const SizedBox(width: 12),
                                const Text('Copy Content', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                HugeIcon(icon: HugeIcons.strokeRoundedShare01, size: 18, color: theme.colorScheme.onSurface),
                                const SizedBox(width: 12),
                                const Text('Share', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: 18, color: theme.colorScheme.error),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: theme.colorScheme.error, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      body: detailAsync.when(
        data: (notification) {
          if (notification == null) {
            return const Center(child: Text('Notification not found'));
          }
          return _buildContent(context, notification);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationModel notification) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = CategoryModel.findById(notification.category);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + kToolbarHeight + 12,
        16,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Source Card (flat)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // App avatar clean flat
                _buildAvatar(theme, notification, category, isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.appName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.packageName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Open App Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _launchSourceApp(context, notification),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowUpRight01,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Metadata Card (flat)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  HugeIcons.strokeRoundedClock01,
                  'Captured At',
                  '${notification.timestamp.fullDateString} at ${notification.timestamp.timeString}',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    height: 1,
                  ),
                ),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFolder01,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    CategoryChip(category: category),
                  ],
                ),
                if (notification.senderName != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      height: 1,
                    ),
                  ),
                  _buildInfoRow(
                    context,
                    HugeIcons.strokeRoundedUser,
                    'Sender',
                    notification.senderName!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content Title
          if (notification.title != null &&
              notification.title!.isNotEmpty) ...[
            _SectionLabel(label: 'Title'),
            const SizedBox(height: 6),
            SelectableText(
              notification.title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Body
          if (notification.body != null && notification.body!.isNotEmpty) ...[
            _SectionLabel(label: 'Message'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1.0,
                ),
              ),
              child: SelectableText(
                notification.body!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Big Text
          if (notification.bigText != null &&
              notification.bigText!.isNotEmpty &&
              notification.bigText != notification.body) ...[
            _SectionLabel(label: 'Full Content'),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1.0,
                ),
              ),
              child: SelectableText(
                notification.bigText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Extracted info chips
          _buildExtractedData(context, notification),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    List<List<dynamic>> icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        HugeIcon(icon: icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildExtractedData(
      BuildContext context, NotificationModel notification) {
    final content = notification.displayText;
    if (content.isEmpty) return const SizedBox.shrink();

    final otp = NotificationParser.extractOtp(content);
    final amount = NotificationParser.extractAmount(content);
    final upiId = NotificationParser.extractUpiId(content);

    if (otp == null && amount == null && upiId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _SectionLabel(label: 'Extracted Information'),
        const SizedBox(height: 10),
        if (otp != null)
          _buildExtractedChip(context, 'One-Time Password (OTP)', otp,
              HugeIcons.strokeRoundedKey01, AppColors.primary),
        if (amount != null)
          _buildExtractedChip(context, 'Transaction Amount', amount,
              HugeIcons.strokeRoundedCreditCard, AppColors.success),
        if (upiId != null)
          _buildExtractedChip(context, 'UPI/VPA Address', upiId,
              HugeIcons.strokeRoundedPayment01, AppColors.categoryPayments),
      ],
    );
  }

  Widget _buildExtractedChip(
    BuildContext context,
    String label,
    String value,
    List<List<dynamic>> icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          context.showSnackBar('$label copied to clipboard');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, size: 18, color: color),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCopy,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action,
      NotificationModel notification) {
    switch (action) {
      case 'copy':
        final text =
            '${notification.title ?? ''}\n${notification.displayText}';
        Clipboard.setData(ClipboardData(text: text));
        context.showSnackBar('Copied to clipboard');
        break;
      case 'share':
        final text =
            '${notification.appName}: ${notification.title ?? ''}\n${notification.displayText}';
        SharePlus.instance.share(ShareParams(text: text));
        break;
      case 'delete':
        ref
            .read(notificationRepositoryProvider)
            .deleteNotification(notificationId);
        Navigator.of(context).pop();
        break;
    }
  }

  Future<void> _launchSourceApp(
      BuildContext context, NotificationModel notification) async {
    // Extract the original notification key from the stored ID.
    // ID format: "{originalKey}_{timestampMs}"
    final id = notification.id;
    final lastUnderscore = id.lastIndexOf('_');
    final notificationKey = lastUnderscore > 0 ? id.substring(0, lastUnderscore) : id;

    final launched = await LaunchAppHelper.launchNotificationContent(
      packageName: notification.packageName,
      notificationKey: notificationKey,
    );
    if (!launched && context.mounted) {
      context.showSnackBar('Could not open ${notification.appName}');
    }
  }

  Widget _buildAvatar(
    ThemeData theme,
    NotificationModel notification,
    CategoryModel category,
    bool isDark,
  ) {
    String? path = notification.iconPath;
    if (path == null || path.isEmpty) {
      path = '/data/user/0/com.notifyvault.app/files/icons/${notification.packageName}.png';
    }

    final file = File(path);
    if (file.existsSync()) {
      return Container(
        width: 50,
        height: 50,
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
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackAvatar(theme, notification, category),
          ),
        ),
      );
    }
    return _buildFallbackAvatar(theme, notification, category);
  }

  Widget _buildFallbackAvatar(
    ThemeData theme,
    NotificationModel notification,
    CategoryModel category,
  ) {
    return Container(
      width: 50,
      height: 50,
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
          size: 24,
          color: category.color,
        ),
      ),
    );
  }

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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 10,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
