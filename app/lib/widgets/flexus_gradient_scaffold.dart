import 'package:flutter/material.dart';

class FlexusGradientScaffold extends StatelessWidget {
  final Widget child;
  final Color topColor;
  final Color bottomColor;

  const FlexusGradientScaffold({
    super.key,
    required this.child,
    required this.topColor,
    required this.bottomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      body: Container(
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.centerRight,
            colors: [topColor, bottomColor],
          ),
        ),
        child: child,
      ),
    );
  }
}
