import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusFloatingActionButton extends StatelessWidget {
  final Function() onPressed;

  const FlexusFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: AppSettings.fontV1,
      backgroundColor: AppSettings.primary,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: Icon(
        Icons.add,
        size: AppSettings.fontSizeMainTitle,
      ),
    );
  }
}
