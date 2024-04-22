import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class DocumentWorkoutPage extends StatelessWidget {
  const DocumentWorkoutPage({
    super.key,
    required this.splitID,
  });

  final int? splitID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomDefaultTextStyle(text: 'DocumentWorkoutPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            CustomDefaultTextStyle(text: "Not implemented yet"),
          ],
        ),
      ),
    );
  }
}
