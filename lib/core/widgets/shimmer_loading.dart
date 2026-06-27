import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading placeholder for notification lists.
class ShimmerLoading extends StatelessWidget {
  final int itemCount;

  const ShimmerLoading({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2435) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF2A3146) : const Color(0xFFF1F5F9),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildItem(),
      ),
    );
  }

  Widget _buildItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar placeholder
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 12),

          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 45,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 200,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 65,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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

/// Shimmer loading for dashboard cards.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2435) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF2A3146) : const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCard(96)),
                const SizedBox(width: 12),
                Expanded(child: _buildCard(96)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCard(96)),
                const SizedBox(width: 12),
                Expanded(child: _buildCard(96)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
