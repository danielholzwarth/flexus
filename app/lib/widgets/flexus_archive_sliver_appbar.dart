import 'package:app/pages/home/archive.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FlexusArchiveSliverAppBar extends StatelessWidget {
  const FlexusArchiveSliverAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 30,
      backgroundColor: AppSettings.background,
      surfaceTintColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      expandedHeight: 30,
      centerTitle: true,
      title: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: ArchivePage(),
            ),
          );
        },
        child: const Text("Archive"),
      ),
    );
  }
}
