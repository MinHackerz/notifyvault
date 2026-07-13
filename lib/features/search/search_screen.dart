import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/search_providers.dart';
import '../../providers/notification_providers.dart';
import '../../core/widgets/notification_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../models/category_model.dart';
import '../../core/widgets/banner_ad_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref
                        .read(recentSearchesProvider.notifier)
                        .addSearch(value.trim());
                  }
                },
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
          ),

          // Search Filters
          _buildSearchFilters(context),

          // Content
          Expanded(
            child: (query.isEmpty &&
                    ref.watch(searchFilterProvider).categoryId == null &&
                    ref.watch(searchFilterProvider).onlyUnread == null)
                ? _buildEmptyOrRecent(context, recentSearches)
                : _buildPageResults(context, resultsAsync),
          ),
        ],
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
    AsyncValue resultsAsync,
  ) {
    return resultsAsync.when(
      data: (results) {
        final list = results as List;
        if (list.isEmpty) {
          return EmptyState(
            icon: HugeIcons.strokeRoundedSearch01,
            title: 'No results found',
            subtitle: 'Try a different keyword or check your spelling.',
          );
        }

        return ListView.builder(
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: HugeIcons.strokeRoundedAlertCircle,
        title: 'Search error',
        subtitle: error.toString(),
      ),
    );
  }

  Widget _buildSearchFilters(BuildContext context) {
    final activeFilter = ref.watch(searchFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 44,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Unread Only Filter Chip
          ChoiceChip(
            label: const Text('Unread Only'),
            selected: activeFilter.onlyUnread == true,
            onSelected: (selected) {
              ref.read(searchFilterProvider.notifier).setFilter(SearchFilter(
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

          // Divider/Separator
          VerticalDivider(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 16,
            thickness: 1,
            indent: 6,
            endIndent: 6,
          ),
          const SizedBox(width: 8),

          // Category Chips
          ...CategoryModel.all.map((cat) {
            final isSelected = activeFilter.categoryId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(searchFilterProvider.notifier).setFilter(SearchFilter(
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
    );
  }
}
