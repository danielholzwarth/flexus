import 'package:app/bloc/statistic_bloc/statistic_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlexusStatisticsExpansionTile extends StatefulWidget {
  final String title;
  final int diagramType;
  final String? query;

  const FlexusStatisticsExpansionTile({
    super.key,
    required this.title,
    required this.diagramType,
    this.query,
  });

  @override
  State<FlexusStatisticsExpansionTile> createState() => _FlexusStatisticsExpansionTileState();
}

class _FlexusStatisticsExpansionTileState extends State<FlexusStatisticsExpansionTile> {
  StatisticBloc statisticBloc = StatisticBloc();
  int touchIndex = -1;

  List<Color> primaryColors = [
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    statisticBloc.add(GetStatistic(title: widget.title, diagramType: widget.diagramType, periodInDays: 7));
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return ExpansionTile(
      initiallyExpanded: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightText(widget.title, AppSettings.fontSizeH4),
        ],
      ),
      children: <Widget>[buildDiagram(deviceSize, widget.diagramType)],
    );
  }

  Widget buildDiagram(Size deviceSize, int diagramType) {
    return SizedBox(
      height: deviceSize.width * 0.8,
      width: deviceSize.width * 0.8,
      child: Center(
          child: BlocBuilder(
        bloc: statisticBloc,
        builder: (context, state) {
          if (state is StatisticLoaded) {
            switch (diagramType) {
              case 0:
                return buildPieChart(deviceSize);

              case 1:
                return buildBarChart();

              default:
                return const CustomDefaultTextStyle(text: "Unknown diagram type!");
            }
          } else if (state is StatisticError) {
            return Center(
                child: FlexusError(
                    text: state.error,
                    func: () => statisticBloc.add(GetStatistic(title: widget.title, diagramType: widget.diagramType, periodInDays: 7))));
          } else {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
        },
      )),
    );
  }

  BarChart buildBarChart() {
    return BarChart(
      BarChartData(
        backgroundColor: AppSettings.background,
      ),
    );
  }

  PieChart buildPieChart(Size deviceSize) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (p0, p1) {
            setState(() {
              if (!p0.isInterestedForInteractions || p1 == null || p1.touchedSection == null) {
                touchIndex = -1;
                return;
              }
              touchIndex = p1.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: List.generate(
          4,
          (index) => PieChartSectionData(
              value: (index + 1),
              radius: touchIndex == index ? deviceSize.width * 0.38 : deviceSize.width * 0.3,
              color: primaryColors[index],
              titleStyle: TextStyle(
                fontSize: touchIndex == index ? AppSettings.fontSizeH4 : AppSettings.fontSize,
              )),
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
      ),
    );
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
