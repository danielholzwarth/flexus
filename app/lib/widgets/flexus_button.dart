import 'package:app/resources/app_colors.dart';
import 'package:app/resources/user_settings.dart';
import 'package:flutter/material.dart';

class FlexusButton extends StatelessWidget {
  const FlexusButton({
    super.key,
    required this.text,
    required this.route,
    this.backgroundColor,
    this.fontColor,
  });
  final String text;
  final String route;
  final Color? backgroundColor;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(backgroundColor ?? AppColors.background), elevation: MaterialStateProperty.all(10)),
      child: SizedBox(
        width: screenWidth * 0.5,
        height: screenHeight * 0.08,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: fontColor ?? AppColors.font,
              fontSize: UserAppSettings.fontsize - 2,
            ),
          ),
        ),
      ),
    );
  }
}
