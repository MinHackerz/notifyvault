import '../../models/notification_model.dart';

enum EventType {
  delivery,
  bill,
  appointment,
  subscription,
  general,
}

class DetectedActionableEvent {
  final EventType type;
  final String title;
  final String description;
  final DateTime suggestedTime;
  final String categoryLabel;

  const DetectedActionableEvent({
    required this.type,
    required this.title,
    required this.description,
    required this.suggestedTime,
    required this.categoryLabel,
  });
}

/// Helper class to parse actionable event dates and descriptions from notification text.
class ReminderParser {
  ReminderParser._();

  static final List<RegExp> _deliveryKeywords = [
    RegExp(r'\b(?:delivering|out for delivery|arriving|shipment|package|delivery scheduled|expected by|order arriving)\b', caseSensitive: false),
  ];

  static final List<RegExp> _billKeywords = [
    RegExp(r'\b(?:bill|due date|payment due|due on|pay by|recharge due|statement due|amount due|due date is)\b', caseSensitive: false),
  ];

  static final List<RegExp> _appointmentKeywords = [
    RegExp(r'\b(?:appointment|scheduled|booking|flight|train|bus|doctor|meeting|interview|ticket|reservation)\b', caseSensitive: false),
  ];

  static final List<RegExp> _subscriptionKeywords = [
    RegExp(r'\b(?:renew|renewal|subscription|membership|plan expiring|expires on)\b', caseSensitive: false),
  ];

  /// Detect if a notification contains an actionable event.
  static DetectedActionableEvent? parse(NotificationModel notification) {
    final text = '${notification.title ?? ''} ${notification.displayText}'.trim();
    if (text.isEmpty) return null;

    EventType? eventType;
    String categoryLabel = 'Reminder';

    for (final pattern in _deliveryKeywords) {
      if (pattern.hasMatch(text)) {
        eventType = EventType.delivery;
        categoryLabel = 'Delivery Event';
        break;
      }
    }

    if (eventType == null) {
      for (final pattern in _billKeywords) {
        if (pattern.hasMatch(text)) {
          eventType = EventType.bill;
          categoryLabel = 'Bill Due Event';
          break;
        }
      }
    }

    if (eventType == null) {
      for (final pattern in _appointmentKeywords) {
        if (pattern.hasMatch(text)) {
          eventType = EventType.appointment;
          categoryLabel = 'Booking / Appointment';
          break;
        }
      }
    }

    if (eventType == null) {
      for (final pattern in _subscriptionKeywords) {
        if (pattern.hasMatch(text)) {
          eventType = EventType.subscription;
          categoryLabel = 'Subscription Renewal';
          break;
        }
      }
    }

    // If no specific event type keyword was found, return null
    if (eventType == null) return null;

    // Extract target date
    final detectedDate = _extractDateTime(text, notification.timestamp);

    final eventTitle = _buildTitle(notification, eventType);
    final eventDesc = notification.title != null && notification.title!.isNotEmpty
        ? notification.title!
        : notification.appName;

    return DetectedActionableEvent(
      type: eventType,
      title: eventTitle,
      description: eventDesc,
      suggestedTime: detectedDate,
      categoryLabel: categoryLabel,
    );
  }

  static String _buildTitle(NotificationModel notification, EventType type) {
    switch (type) {
      case EventType.delivery:
        return '${notification.appName} Package Delivery';
      case EventType.bill:
        return '${notification.appName} Bill Due';
      case EventType.appointment:
        return '${notification.appName} Scheduled Event';
      case EventType.subscription:
        return '${notification.appName} Subscription Renewal';
      case EventType.general:
        return 'Follow up on ${notification.appName}';
    }
  }

  /// Parse exact or relative date from text and compute reminder 1 hour prior to event time.
  static DateTime _extractDateTime(String text, DateTime fallbackBase) {
    final lower = text.toLowerCase();
    final now = DateTime.now();

    // 1. Extract explicit time of day from text e.g. "at 4 PM", "3:30 PM", "at 16:00", "4pm"
    int? parsedHour;
    int? parsedMinute;

    final explicitTimeMatch = RegExp(
      r'\b(?:at|@)?\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b|\b(?:at|@)\s*(\d{1,2})(?::(\d{2}))?\b',
      caseSensitive: false,
    ).firstMatch(text);

    if (explicitTimeMatch != null) {
      int h = int.parse(explicitTimeMatch.group(1) ?? explicitTimeMatch.group(4) ?? '9');
      int m = int.parse(explicitTimeMatch.group(2) ?? explicitTimeMatch.group(5) ?? '0');
      final amPm = (explicitTimeMatch.group(3) ?? '').toLowerCase();

      if (amPm == 'pm' && h < 12) h += 12;
      if (amPm == 'am' && h == 12) h = 0;

      // A bare hour with no am/pm ("meeting at 4") is far more likely to mean
      // the afternoon than 04:00 — reading it as AM would put the reminder at
      // 3 in the morning. Hours 1-7 are treated as PM; 8-11 stay AM, and 12-23
      // are already unambiguous on a 24-hour reading.
      if (amPm.isEmpty && h >= 1 && h <= 7) h += 12;

      parsedHour = h;
      parsedMinute = m;
    }

    // 2. Determine target day
    DateTime targetDate;
    // Whether the text actually named a day. Only a guessed day may be rolled
    // forward when the resulting time has already passed.
    bool hasExplicitDate = true;
    if (lower.contains('today')) {
      targetDate = DateTime(now.year, now.month, now.day);
    } else if (lower.contains('tomorrow')) {
      final t = now.add(const Duration(days: 1));
      targetDate = DateTime(t.year, t.month, t.day);
    } else {
      final dateMatch = RegExp(
        r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\b',
        caseSensitive: false,
      ).firstMatch(text);

      if (dateMatch != null) {
        final day = int.tryParse(dateMatch.group(1) ?? '') ?? now.day;
        final monthStr = (dateMatch.group(2) ?? '').toLowerCase();
        final month = _monthFromStr(monthStr);
        int year = now.year;
        DateTime candidate = DateTime(year, month, day);
        if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
          candidate = DateTime(year + 1, month, day);
        }
        targetDate = candidate;
      } else {
        targetDate = DateTime(now.year, now.month, now.day);
        hasExplicitDate = false;
      }
    }

    int hour = parsedHour ?? 18;
    int minute = parsedMinute ?? 0;

    DateTime eventTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );

    // Only shift a guessed day. Rolling an explicitly stated date ("15 Jan",
    // "today at 4") into the next day would contradict the notification text.
    if (eventTime.isBefore(now) && !hasExplicitDate) {
      eventTime = eventTime.add(const Duration(days: 1));
    }

    // RULE: Suggested reminder time MUST be 1 HOUR PRIOR to the message event time
    DateTime suggestedReminder = eventTime.subtract(const Duration(hours: 1));

    if (suggestedReminder.isBefore(now)) {
      suggestedReminder = now.add(const Duration(minutes: 15));
    }

    return suggestedReminder;
  }

  static int _monthFromStr(String str) {
    switch (str.substring(0, 3)) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      default: return DateTime.now().month;
    }
  }
}
