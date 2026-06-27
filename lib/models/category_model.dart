import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../app/theme/app_colors.dart';

/// Represents a notification category with display properties.
class CategoryModel {
  final String id;
  final String name;
  final List<List<dynamic>> icon;
  final Color color;
  final int notificationCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.notificationCount = 0,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    List<List<dynamic>>? icon,
    Color? color,
    int? notificationCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }

  /// All predefined categories.
  static const List<CategoryModel> all = [
    CategoryModel(
      id: 'otp',
      name: 'OTP',
      icon: HugeIcons.strokeRoundedKey01,
      color: AppColors.categoryOtp,
    ),
    CategoryModel(
      id: 'banking',
      name: 'Banking',
      icon: HugeIcons.strokeRoundedBank,
      color: AppColors.categoryBanking,
    ),
    CategoryModel(
      id: 'payments',
      name: 'Payments',
      icon: HugeIcons.strokeRoundedCreditCard,
      color: AppColors.categoryPayments,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      icon: HugeIcons.strokeRoundedShoppingBag01,
      color: AppColors.categoryShopping,
    ),
    CategoryModel(
      id: 'delivery',
      name: 'Delivery',
      icon: HugeIcons.strokeRoundedDeliveryTruck01,
      color: AppColors.categoryDelivery,
    ),
    CategoryModel(
      id: 'social',
      name: 'Social',
      icon: HugeIcons.strokeRoundedUser,
      color: AppColors.categorySocial,
    ),
    CategoryModel(
      id: 'messages',
      name: 'Messages',
      icon: HugeIcons.strokeRoundedBubbleChat,
      color: AppColors.categoryMessages,
    ),
    CategoryModel(
      id: 'email',
      name: 'Email',
      icon: HugeIcons.strokeRoundedMail01,
      color: AppColors.categoryEmail,
    ),
    CategoryModel(
      id: 'work',
      name: 'Work',
      icon: HugeIcons.strokeRoundedBriefcase01,
      color: AppColors.categoryWork,
    ),
    CategoryModel(
      id: 'government',
      name: 'Government',
      icon: HugeIcons.strokeRoundedBank,
      color: AppColors.categoryGovernment,
    ),
    CategoryModel(
      id: 'education',
      name: 'Education',
      icon: HugeIcons.strokeRoundedBookOpen01,
      color: AppColors.categoryEducation,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      icon: HugeIcons.strokeRoundedHospital01,
      color: AppColors.categoryHealth,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: HugeIcons.strokeRoundedFilm01,
      color: AppColors.categoryEntertainment,
    ),
    CategoryModel(
      id: 'promotions',
      name: 'Promotions',
      icon: HugeIcons.strokeRoundedDiscount,
      color: AppColors.categoryPromotions,
    ),
    CategoryModel(
      id: 'spam',
      name: 'Spam',
      icon: HugeIcons.strokeRoundedAlertCircle,
      color: AppColors.categorySpam,
    ),
    CategoryModel(
      id: 'other',
      name: 'Other',
      icon: HugeIcons.strokeRoundedNotification01,
      color: AppColors.categoryOther,
    ),
  ];

  /// Find a category by id.
  static CategoryModel findById(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => all.last, // 'other'
    );
  }
}
