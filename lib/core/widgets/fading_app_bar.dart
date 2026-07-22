import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// A custom AppBar wrapper that provides a fading bottom gradient
/// ONLY when content scrolls underneath it.
class FadingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double toolbarHeight;
  final double fadeHeight;
  final bool isScrolled;

  const FadingAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
    this.fadeHeight = 20.0,
    this.isScrolled = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + (isScrolled ? fadeHeight : 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : theme.scaffoldBackgroundColor;
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: topInset + toolbarHeight + fadeHeight,
      child: Stack(
        children: [
          // Solid Background for Status Bar + Toolbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + toolbarHeight,
            child: Container(
              color: bgColor,
            ),
          ),

          // Fading Bottom Gradient Overlay (Only visible when scrolled)
          Positioned(
            top: topInset + toolbarHeight,
            left: 0,
            right: 0,
            height: fadeHeight,
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

          // AppBar Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + toolbarHeight,
            child: AppBar(
              title: title,
              leading: leading,
              actions: actions,
              centerTitle: centerTitle,
              automaticallyImplyLeading: automaticallyImplyLeading,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// A Scaffold wrapper that automatically monitors scroll position
/// and toggles the top bar bottom fading gradient when scrolling.
class FadingScaffold extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double toolbarHeight;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const FadingScaffold({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  State<FadingScaffold> createState() => _FadingScaffoldState();
}

class _FadingScaffoldState extends State<FadingScaffold> {
  bool _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: FadingAppBar(
        title: widget.title,
        leading: widget.leading,
        actions: widget.actions,
        centerTitle: widget.centerTitle,
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        toolbarHeight: widget.toolbarHeight,
        isScrolled: _isScrolled,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
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
        child: widget.body,
      ),
    );
  }
}
