import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusDefaultIcon extends StatelessWidget {
  final IconData iconData;
  final double? iconSize;
  final Color? iconColor;

  const FlexusDefaultIcon({
    super.key,
    required this.iconData,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      size: iconSize ?? AppSettings.fontSizeH3,
      color: iconColor ?? AppSettings.font,
    );
  }
}
