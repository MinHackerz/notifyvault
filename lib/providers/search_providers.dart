import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../app/config/app_config.dart';
import 'notification_providers.dart';

/// Current search query.
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

class SearchFilter {
  final String? categoryId;
  final bool? onlyUnread;

  const SearchFilter({this.categoryId, this.onlyUnread});
}

class SearchFilterNotifier extends Notifier<SearchFilter> {
  @override
  SearchFilter build() => const SearchFilter();

  void setFilter(SearchFilter filter) => state = filter;
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilter>(SearchFilterNotifier.new);

/// Instant search results from local database.
final searchResultsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  // Re-evaluate when notifications change
  ref.watch(notificationStreamProvider);

  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final repo = ref.read(notificationRepositoryProvider);

  if (query.trim().isEmpty) {
    if (filter.categoryId == null && filter.onlyUnread == null) {
      return [];
    }
    List<NotificationModel> results;
    if (filter.categoryId != null) {
      results = await repo.getByCategory(filter.categoryId!, limit: 100);
    } else {
      results = await repo.getNotifications(limit: 100);
    }
    if (filter.onlyUnread != null) {
      results = results.where((n) => filter.onlyUnread! ? !n.isRead : n.isRead).toList();
    }
    return results;
  }

  var results = await repo.searchNotifications(query.trim(), limit: 100);

  // Apply category filter
  if (filter.categoryId != null) {
    results = results.where((n) => n.category == filter.categoryId).toList();
  }
  // Apply read status filter
  if (filter.onlyUnread != null) {
    results = results.where((n) => filter.onlyUnread! ? !n.isRead : n.isRead).toList();
  }

  return results;
});

/// Recent searches stored in memory.
final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
        RecentSearchesNotifier.new);

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    final updated = [
      query.trim(),
      ...state.where((s) => s != query.trim()),
    ].take(AppConfig.maxRecentSearches).toList();

    state = updated;
  }

  void removeSearch(String query) {
    state = state.where((s) => s != query).toList();
  }

  void clear() {
    state = [];
  }
}
