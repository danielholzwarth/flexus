import 'package:flutter/material.dart';

class FlexusBottomSizedBox extends StatelessWidget {
  const FlexusBottomSizedBox({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: screenHeight * 0.12);
  }
}
