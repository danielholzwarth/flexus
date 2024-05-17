import 'package:app/hive/statistic/statistic.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_statistics_expansion_tile.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  ScrollController scrollController = ScrollController();

  List<Statistic> statistics = [
    Statistic(title: "Total Moved Weight", labelX: "Days of Week", labelY: "(in tons)", diagramType: 2),
    Statistic(title: "Total Reps", labelX: "Days of Week", labelY: "", diagramType: 2),
    Statistic(title: "Workout Days", labelX: "", labelY: "(all time)", diagramType: 0),
    Statistic(title: "Workout Duration", labelX: "Days of Week", labelY: "(in mins)", diagramType: 2),
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
        title: CustomDefaultTextStyle(
          text: 'Statistics',
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
      ),
      body: FlexusScrollBar(
        scrollController: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: statistics.map((s) {
              return FlexusStatisticsExpansionTile(statistic: s);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
