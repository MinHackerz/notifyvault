import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_providers.dart';
import '../../models/notification_model.dart';
import '../../models/category_model.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/helpers/notification_parser.dart';
import '../../core/helpers/reminder_parser.dart';
import '../../core/helpers/launch_app_helper.dart';
import '../../core/widgets/category_chip.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/reminder_providers.dart';

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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotificationOff01,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Notification Archived or Moved',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The original notification item is no longer in active log, but your scheduled reminders remain active.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.go('/timeline'),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedTime02,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: const Text('Timeline'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedHome01,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text('Dashboard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContent(context, ref, notification);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, NotificationModel notification) {
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
                InkWell(
                  onTap: () => _showCategorySelectorSheet(context, ref, notification),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
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
                        const SizedBox(width: 4),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedEdit02,
                          size: 12,
                          color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        ),
                        const Spacer(),
                        CategoryChip(category: category),
                      ],
                    ),
                  ),
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

          const SizedBox(height: 16),

          // Smart Actionable Reminder Section
          _buildSmartReminderSection(context, ref, notification),
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

  Widget _buildSmartReminderSection(
      BuildContext context, WidgetRef ref, NotificationModel notification) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final event = ReminderParser.parse(notification);
    final existingReminderAsync = ref.watch(existingReminderForNotificationProvider(notification.id));
    final existingReminder = existingReminderAsync.value;

    final isReminderSet = existingReminder != null;

    if (event != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isReminderSet
              ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
              : theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReminderSet
                ? AppColors.success.withValues(alpha: 0.35)
                : theme.colorScheme.primary.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isReminderSet ? AppColors.success : theme.colorScheme.primary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HugeIcon(
                    icon: isReminderSet
                        ? HugeIcons.strokeRoundedCheckmarkCircle02
                        : HugeIcons.strokeRoundedCalendar01,
                    size: 16,
                    color: isReminderSet ? AppColors.success : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isReminderSet
                      ? 'REMINDER ACTIVE'
                      : event.categoryLabel.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isReminderSet ? AppColors.success : theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isReminderSet ? existingReminder.title : event.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isReminderSet
                  ? 'Scheduled for: ${_formatDateTime(existingReminder.scheduledAt)}'
                  : 'Suggested reminder: ${_formatDateTime(event.suggestedTime)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showScheduleReminderSheet(
                  context,
                  ref,
                  notification,
                  event,
                  existingReminder: existingReminder,
                ),
                icon: HugeIcon(
                  icon: isReminderSet
                      ? HugeIcons.strokeRoundedEdit02
                      : HugeIcons.strokeRoundedAlarmClock,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  isReminderSet ? 'Update Existing Reminder' : 'Set Reminder',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReminderSet ? AppColors.success : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => _showScheduleReminderSheet(
        context,
        ref,
        notification,
        null,
        existingReminder: existingReminder,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isReminderSet
              ? AppColors.success.withValues(alpha: isDark ? 0.12 : 0.06)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReminderSet
                ? AppColors.success.withValues(alpha: 0.3)
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isReminderSet ? AppColors.success : theme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: HugeIcon(
                icon: isReminderSet
                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                    : HugeIcons.strokeRoundedAlarmClock,
                size: 18,
                color: isReminderSet ? AppColors.success : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReminderSet ? 'Update Existing Reminder' : 'Set Follow-up Reminder',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    isReminderSet
                        ? 'Scheduled for ${_formatDateTime(existingReminder.scheduledAt)}'
                        : 'Schedule a local reminder for this notification',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${DateFormat('jm').format(dt)}';
  }

  void _showScheduleReminderSheet(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    DetectedActionableEvent? event, {
    ReminderItem? existingReminder,
  }) {
    final theme = Theme.of(context);
    final initialDate = existingReminder?.scheduledAt ?? event?.suggestedTime ?? DateTime.now().add(const Duration(days: 1));
    DateTime selectedDateTime = initialDate.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(hours: 1))
        : initialDate;

    final titleController = TextEditingController(
      text: existingReminder?.title ?? event?.title ?? 'Follow up: ${notification.appName}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        existingReminder != null ? 'Update Reminder' : 'Schedule Reminder',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      if (existingReminder != null)
                        IconButton(
                          tooltip: 'Delete Reminder',
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref.read(reminderControllerProvider).deleteReminder(existingReminder.id);
                            context.showSnackBar('Reminder deleted.');
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Reminder Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scheduled Date & Time',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final initialForPicker = selectedDateTime.isBefore(now) ? now : selectedDateTime;
                      final firstForPicker = selectedDateTime.isBefore(now)
                          ? selectedDateTime.subtract(const Duration(days: 1))
                          : now;

                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: initialForPicker,
                        firstDate: firstForPicker,
                        lastDate: now.add(const Duration(days: 365)),
                        builder: (ctx, child) => Theme(data: theme, child: child!),
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                          builder: (ctx, child) => Theme(data: theme, child: child!),
                        );
                        if (pickedTime != null) {
                          setModalState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatDateTime(selectedDateTime),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            'Change',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final title = titleController.text.trim().isNotEmpty
                            ? titleController.text.trim()
                            : 'Reminder: ${notification.appName}';

                        final success = await ref
                            .read(reminderControllerProvider)
                            .scheduleReminder(
                              notification: notification,
                              title: title,
                              scheduledTime: selectedDateTime,
                            );

                        if (context.mounted) {
                          if (success) {
                            context.showSnackBar(
                              existingReminder != null
                                  ? 'Reminder updated for ${_formatDateTime(selectedDateTime)}'
                                  : 'Reminder scheduled for ${_formatDateTime(selectedDateTime)}',
                            );
                          } else {
                            context.showSnackBar('Failed to schedule reminder. Please check permissions.');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: existingReminder != null ? AppColors.success : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        existingReminder != null ? 'Update Reminder' : 'Confirm Reminder',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  void _showCategorySelectorSheet(
      BuildContext context, WidgetRef ref, NotificationModel notification) {
    final theme = Theme.of(context);
    final categories = CategoryModel.all;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Category for ${notification.appName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All past and future notifications from ${notification.appName} will be categorized as your selection.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = notification.category == cat.id;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : null,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: cat.icon,
                              color: cat.color,
                              size: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          cat.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () async {
                          Navigator.pop(context);
                          await ref
                              .read(notificationRepositoryProvider)
                              .updateAppCategoryOverride(
                                packageName: notification.packageName,
                                appName: notification.appName,
                                category: cat.id,
                              );
                          ref.invalidate(notificationDetailProvider(notification.id));
                          ref.invalidate(notificationStreamProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Set category to "${cat.name}" for ${notification.appName}',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
