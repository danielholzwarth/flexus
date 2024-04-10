import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        backgroundColor: AppSettings.background,
        title: const CustomDefaultTextStyle(text: 'StatisticsPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: CustomDefaultTextStyle(text: "Stats"),
      ),
    );
  }
}
