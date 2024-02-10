import 'package:flutter/material.dart';

class FlexusGradientContainer extends StatelessWidget {
  final Widget child;
  final Color topColor;
  final Color bottomColor;

  const FlexusGradientContainer({
    super.key,
    required this.child,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
          colors: [topColor, bottomColor],
        ),
      ),
      child: child,
    );
  }
}
