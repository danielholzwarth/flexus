import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusSliverAppBar extends StatelessWidget {
  final Widget? leading;
  final bool hasLeading;
  final Widget? title;
  final List<Widget>? actions;
  final bool isPinned;
  final bool isFloating;
  final bool isSnap;

  const FlexusSliverAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.hasLeading = true,
    this.isPinned = true,
    this.isFloating = true,
    this.isSnap = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppSettings.background,
      surfaceTintColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      pinned: isPinned,
      floating: isFloating,
      leading: leading,
      automaticallyImplyLeading: hasLeading,
      title: title,
      centerTitle: title != null ? true : false,
      actions: actions,
      snap: isSnap,
    );
  }
}
