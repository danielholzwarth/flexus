import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:flutter/material.dart';

class FlexusFloatingActionButton extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;

  const FlexusFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      foregroundColor: AppSettings.fontV1,
      backgroundColor: AppSettings.primary,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: FlexusDefaultIcon(
        iconData: icon,
        iconSize: AppSettings.fontSizeH1,
        iconColor: AppSettings.fontV1,
      ),
    );
  }
}
