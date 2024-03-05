import 'package:app/resources/app_settings.dart';
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
    return SizedBox(
      width: AppSettings.screenWidth * 0.7,
      child: Row(
        children: [
          Icon(
            condition ? Icons.circle : Icons.circle_outlined,
            size: 14,
            color: condition ? const Color.fromARGB(255, 23, 117, 26) : const Color.fromARGB(255, 128, 13, 5),
          ),
          SizedBox(width: AppSettings.screenWidth * 0.02),
          Text(
            text,
            style: TextStyle(
              color: condition ? AppSettings.confirm : AppSettings.error,
              fontSize: AppSettings.fontSize,
            ),
          )
        ],
      ),
    );
  }
}
