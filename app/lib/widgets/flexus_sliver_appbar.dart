import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusSliverAppBar extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  const FlexusSliverAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppSettings.background,
      surfaceTintColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      toolbarHeight: 50,
      expandedHeight: 50,
      floating: true,
      leading: leading,
      title: title,
      centerTitle: title != null ? true : false,
      actions: actions,
      snap: true,
    );
  }
}
