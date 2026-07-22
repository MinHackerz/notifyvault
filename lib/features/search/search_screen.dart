import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/search_providers.dart';
import '../../providers/notification_providers.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../models/category_model.dart';
import '../../models/notification_model.dart';
import '../../core/widgets/banner_ad_widget.dart';

/// Animated Search Input Box with subtle idle border and active primary glow
class _SearchInputBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final ValueChanged<String> onSubmitted;

  const _SearchInputBox({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.onSubmitted,
  });

  @override
  State<_SearchInputBox> createState() => _SearchInputBoxState();
}

class _SearchInputBoxState extends State<_SearchInputBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = widget.focusNode.hasFocus || widget.query.isNotEmpty;

    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

    final activeBorderColor = theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 46,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? activeBorderColor : defaultBorderColor,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 18,
            ),
          ),
          suffixIcon: widget.query.isNotEmpty
              ? IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => widget.controller.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}

/// Pinned App Bar for Search Screen containing Title, Search Input Box,
/// and Filter Chips, with a bottom fading gradient overlay.
class SearchFadingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final SearchFilter activeFilter;
  final ValueChanged<SearchFilter> onFilterChanged;
  final ValueChanged<String> onSubmitted;
  final bool isScrolled;

  const SearchFadingAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSubmitted,
    this.isScrolled = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(188 + (isScrolled ? 20 : 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : theme.scaffoldBackgroundColor;
    final topInset = MediaQuery.paddingOf(context).top;
    final headerHeight = topInset + 188.0;

    return SizedBox(
      height: headerHeight + 20,
      child: Stack(
        children: [
          // Solid Background for Header Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(color: bgColor),
          ),

          // Fading Gradient Overlay sitting right below the filter chips
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            height: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              opacity: isScrolled ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Header Contents (Title + Search Field + Filter Chips)
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            height: 188,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with generous 32dp space below
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  child: Text(
                    'Search',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontSize: 22,
                    ),
                  ),
                ),

                // Search Bar Box with side padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchInputBox(
                    controller: controller,
                    focusNode: focusNode,
                    query: query,
                    onSubmitted: onSubmitted,
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Chips Row ("Unread Only", "Payments", "Social", "OTP", etc.)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Unread Only Chip
                      ChoiceChip(
                        label: const Text('Unread Only'),
                        selected: activeFilter.onlyUnread == true,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onSelected: (selected) {
                          onFilterChanged(SearchFilter(
                            categoryId: activeFilter.categoryId,
                            onlyUnread: selected ? true : null,
                          ));
                        },
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: activeFilter.onlyUnread == true
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: activeFilter.onlyUnread == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: activeFilter.onlyUnread == true
                                ? theme.colorScheme.primary
                                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      VerticalDivider(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 12,
                        thickness: 1,
                        indent: 8,
                        endIndent: 8,
                      ),
                      const SizedBox(width: 8),

                      // Category Filter Chips
                      ...CategoryModel.all.map((cat) {
                        final isSelected = activeFilter.categoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            onSelected: (selected) {
                              onFilterChanged(SearchFilter(
                                categoryId: selected ? cat.id : null,
                                onlyUnread: activeFilter.onlyUnread,
                              ));
                            },
                            selectedColor: cat.color.withValues(alpha: 0.15),
                            checkmarkColor: cat.color,
                            labelStyle: TextStyle(
                              color: isSelected ? cat.color : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? cat.color
                                    : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                              ),
                            ),
                          ),
                        );
                      }),
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
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).update(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final activeFilter = ref.watch(searchFilterProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final topPadding = MediaQuery.of(context).padding.top + 188 + 4;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SearchFadingAppBar(
        controller: _searchController,
        focusNode: _focusNode,
        query: query,
        activeFilter: activeFilter,
        isScrolled: _isScrolled,
        onFilterChanged: (filter) {
          ref.read(searchFilterProvider.notifier).setFilter(filter);
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            ref.read(recentSearchesProvider.notifier).addSearch(value.trim());
          }
        },
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            final isScrolled = notification.metrics.pixels > 3;
            if (isScrolled != _isScrolled) {
              setState(() {
                _isScrolled = isScrolled;
              });
            }
          }
          return false;
        },
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: (query.isEmpty && activeFilter.categoryId == null && activeFilter.onlyUnread == null)
              ? _buildEmptyOrRecent(context, recentSearches)
              : _buildPageResults(context, resultsAsync),
        ),
      ),
    );
  }

  Widget _buildEmptyOrRecent(
      BuildContext context, List<String> recentSearches) {
    final theme = Theme.of(context);

    if (recentSearches.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: EmptyState(
              icon: HugeIcons.strokeRoundedSearch01,
              title: 'Search your notifications',
              subtitle:
                  'Find OTPs, amounts, app names, tracking numbers, or any keyword.',
            ),
          ),
          const BannerAdWidget(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          index: '01',
          title: 'Recent Searches',
          action: TextButton(
            onPressed: () {
              ref.read(recentSearchesProvider.notifier).clear();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            child: const Text('Clear All'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _searchController.text = search;
                      _searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: search.length),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedClock01,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            search,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(recentSearchesProvider.notifier)
                                  .removeSearch(search);
                            },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              size: 11,
                              color: theme.colorScheme.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        const BannerAdWidget(),
      ],
    );
  }

  Widget _buildPageResults(
    BuildContext context,
    AsyncValue<List<NotificationModel>> resultsAsync,
  ) {
    final list = resultsAsync.asData?.value ?? [];

    if (resultsAsync.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (resultsAsync.hasError && list.isEmpty) {
      return EmptyState(
        icon: HugeIcons.strokeRoundedAlertCircle,
        title: 'Search error',
        subtitle: resultsAsync.error.toString(),
      );
    }

    if (list.isEmpty) {
      return EmptyState(
        icon: HugeIcons.strokeRoundedSearch01,
        title: 'No results found',
        subtitle: 'Try a different keyword or check your spelling.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notification = list[index];
        return NotificationTile(
          notification: notification,
          enableDismiss: false,
          onTap: () {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.id);
            context.push('/notification/${notification.id}');
          },
        );
      },
    );
  }
}
