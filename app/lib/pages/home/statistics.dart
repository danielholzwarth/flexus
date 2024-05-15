import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/statistics_search_delegate.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_statistics_expansion_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  ScrollController scrollController = ScrollController();

  List<String> statistics = [
    "Average Moved Weight per Day", //Bar
    "Skipped Splits per Plan", //Radar
    "Total Reps per Day", //Bar
    "Weight of Exercise", //Line (filled)
    "Workout Days", //Pie
    "Workout Duration per Day", //Bar
  ];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        backgroundColor: AppSettings.background,
        title: const CustomDefaultTextStyle(text: 'Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FlexusDefaultIcon(iconData: Icons.filter_alt),
            onPressed: () {
              print("filter");
            },
          ),
          IconButton(
            onPressed: () async {
              await showSearch(context: context, delegate: StatisticsSearchDelegate());
            },
            icon: const FlexusDefaultIcon(iconData: Icons.search),
          ),
        ],
      ),
      body: FlexusScrollBar(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              for (int i = 0; i <= statistics.length - 1; i++) FlexusStatisticsExpansionTile(title: statistics[i]),
            ],
          ),
        ),
      ),
    );
  }
}
