import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;

  const FlexusScrollBar({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: AppSettings.primary,
      thickness: 5,
      interactive: true,
      radius: const Radius.circular(30),
      controller: scrollController,
      child: child,
    );
  }
}
