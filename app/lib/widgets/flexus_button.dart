import 'package:app/resources/app_colors.dart';
import 'package:flutter/material.dart';

class FlexusButton extends StatelessWidget {
  const FlexusButton({
    super.key,
    required this.text,
    required this.route,
    this.hasBack = true,
    this.popLast = false,
  });
  final String text;
  final String route;
  final bool hasBack;
  final bool popLast;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (hasBack) {
          if (popLast) {
            Navigator.popAndPushNamed(context, route);
          } else {
            Navigator.pushNamed(context, route);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(AppColors.background)),
      child: Text(
        text,
        style: TextStyle(color: AppColors.font),
      ),
    );
  }
}
