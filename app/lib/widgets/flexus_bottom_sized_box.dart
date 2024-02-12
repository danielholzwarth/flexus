import 'package:flutter/material.dart';

class FlexusBottomSizedBox extends StatelessWidget {
  final double screenHeight;

  const FlexusBottomSizedBox({
    super.key,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: screenHeight * 0.12);
  }
}
