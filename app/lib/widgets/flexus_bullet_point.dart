import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusBulletPoint extends StatelessWidget {
  final String text;
  final bool condition;

  const FlexusBulletPoint({
    super.key,
    required this.text,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: deviceSize.width * 0.7,
      child: Row(
        children: [
          FlexusDefaultIcon(
            iconData: condition ? Icons.circle : Icons.circle_outlined,
            iconSize: AppSettings.fontSizeT3,
            iconColor: condition ? const Color.fromARGB(255, 23, 117, 26) : const Color.fromARGB(255, 128, 13, 5),
          ),
          SizedBox(width: deviceSize.width * 0.02),
          CustomDefaultTextStyle(
            text: text,
            color: condition ? AppSettings.confirm : AppSettings.error,
          ),
        ],
      ),
    );
  }
}
