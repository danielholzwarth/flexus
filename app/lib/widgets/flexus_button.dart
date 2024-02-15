import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusButton extends StatelessWidget {
  final String text;
  final Function() function;
  final Color? backgroundColor;
  final Color? fontColor;

  const FlexusButton({
    super.key,
    required this.text,
    required this.function,
    this.backgroundColor,
    this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.7,
      height: screenHeight * 0.08,
      child: ElevatedButton(
        onPressed: () => function(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor ?? AppSettings.background),
          elevation: MaterialStateProperty.all(AppSettings.elevation),
        ),
        child: Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(
            color: fontColor ?? AppSettings.font,
            fontSize: AppSettings.fontSizeDescription,
          ),
        ),
      ),
    );
  }
}
