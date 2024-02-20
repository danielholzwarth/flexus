import 'package:app/pages/home/archive.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusArchiveSliverAppBar extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool hasLeading;

  const FlexusArchiveSliverAppBar({
    super.key,
    this.actions,
    this.leading,
    this.hasLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: leading,
      automaticallyImplyLeading: hasLeading,
      backgroundColor: AppSettings.background,
      surfaceTintColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      toolbarHeight: 30,
      centerTitle: true,
      actions: actions,
      title: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const ArchivePage(),
            ),
          );
        },
        child: Text(
          "Archive",
          style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font),
        ),
      ),
    );
  }
}
