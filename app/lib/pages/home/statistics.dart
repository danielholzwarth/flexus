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

  //0 - Pie, 1 - Bar, 2 - Line, 3 - Radar
  Map<String, int> statistics = {
    // "Skipped Splits" : 3,
    "Total Moved Weight": 1,
    "Total Reps": 1,
    // "Weight of Exercise" : 2,
    "Workout Days": 0,
    "Workout Duration": 1,
  };

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
            children: statistics.entries.map((e) {
              return FlexusStatisticsExpansionTile(
                title: e.key,
                diagramType: e.value,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
