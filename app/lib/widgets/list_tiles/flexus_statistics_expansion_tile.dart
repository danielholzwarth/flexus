import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FlexusStatisticsExpansionTile extends StatefulWidget {
  final String title;
  final String? query;

  const FlexusStatisticsExpansionTile({
    super.key,
    required this.title,
    this.query,
  });

  @override
  State<FlexusStatisticsExpansionTile> createState() => _FlexusStatisticsExpansionTileState();
}

class _FlexusStatisticsExpansionTileState extends State<FlexusStatisticsExpansionTile> {
  List<Color> primaryColors = [
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightText(widget.title, AppSettings.fontSizeH4),
        ],
      ),
      children: <Widget>[
        SizedBox(height: deviceSize.width * 0.8, width: deviceSize.width * 0.8, child: Center(child: buildDiagram(deviceSize, 3))),
      ],
    );
  }

  Widget buildDiagram(Size deviceSize, int diagramType) {
    switch (diagramType) {
      case 0:
        return PieChart(
          PieChartData(
            sections: List.generate(
              4,
              (index) => PieChartSectionData(value: (index + 1) * 10, radius: deviceSize.width * 0.3, color: primaryColors[index]),
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
          ),
        );

      case 1:
        return BarChart(
          BarChartData(),
        );

      case 2:
        return LineChart(
          LineChartData(),
        );

      case 3:
        return RadarChart(
          RadarChartData(
            dataSets: List.generate(
              4,
              (index) => RadarDataSet(
                  dataEntries: List.generate(3, (index2) => RadarEntry(value: index2 + 1)),
                  entryRadius: deviceSize.width * 0.1,
                  fillColor: primaryColors[index]),
            ),
          ),
        );

      default:
        return Text("unknown diagram type");
    }
  }

  Widget highlightText(String text, double fontSize) {
    if (widget.query != null && widget.query != "") {
      if (text.toLowerCase().contains(widget.query!.toLowerCase())) {
        int startIndex = text.toLowerCase().indexOf(widget.query!.toLowerCase());
        int endIndex = startIndex + widget.query!.length;

        return Row(
          children: [
            CustomDefaultTextStyle(
              text: startIndex > 0 ? text.substring(0, startIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
            CustomDefaultTextStyle(text: text.substring(startIndex, endIndex)),
            CustomDefaultTextStyle(
              text: endIndex < text.length ? text.substring(endIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
          ],
        );
      }
      return CustomDefaultTextStyle(
        text: text,
        color: AppSettings.font.withOpacity(0.5),
      );
    }
    return CustomDefaultTextStyle(text: text);
  }
}
