import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomDefaultTextStyle(text: 'TimerPage'),
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
