import 'package:app/bloc/statistic_bloc/statistic_bloc.dart';
import 'package:app/hive/statistic/statistic.dart';
import 'package:app/pages/plan/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/error/flexus_error.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlexusStatisticsExpansionTile extends StatefulWidget {
  final Statistic statistic;
  final String? query;

  const FlexusStatisticsExpansionTile({
    super.key,
    required this.statistic,
    this.query,
  });

  @override
  State<FlexusStatisticsExpansionTile> createState() => _FlexusStatisticsExpansionTileState();
}

class _FlexusStatisticsExpansionTileState extends State<FlexusStatisticsExpansionTile> {
  StatisticBloc statisticBloc = StatisticBloc();
  int touchIndex = -1;
  int period = 7;

  List<Color> primaryColors = [
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    statisticBloc.add(GetStatistic(title: widget.statistic.title, diagramType: widget.statistic.diagramType, period: 7));
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return ExpansionTile(
      initiallyExpanded: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          highlightText(widget.statistic.title, AppSettings.fontSizeH4),
        ],
      ),
      children: <Widget>[
        SizedBox(height: deviceSize.height * 0.05),
        buildDiagram(deviceSize, widget.statistic.diagramType),
        SizedBox(height: deviceSize.height * 0.02),
      ],
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
            if (state.values.isNotEmpty) {
              switch (diagramType) {
                case 0:
                  return buildPieChart(deviceSize, state.values);

                case 1:
                  return buildBarChart(state.values);

                case 2:
                  return buildLineChart(deviceSize, state.values);

                default:
                  return const CustomDefaultTextStyle(text: "Unknown diagram type!");
              }
            } else {
              return const CustomDefaultTextStyle(text: "No data available!");
            }
          } else if (state is StatisticError) {
            return Center(
              child: FlexusError(
                text: state.error,
                func: () => statisticBloc.add(
                  GetStatistic(title: widget.statistic.title, diagramType: widget.statistic.diagramType, period: 7),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(color: AppSettings.primary));
          }
        },
      )),
    );
  }

  LineChart buildLineChart(Size deviceSize, List<Map<String, dynamic>> values) {
    return LineChart(
      LineChartData(
        minX: 0,
        minY: 0,
        maxX: period.toDouble() - 1,
        maxY: getHighestValueCeiled(values),
        lineBarsData: values.map((line) {
          int lineIndex = values.indexOf(line);

          return LineChartBarData(
            spots: buildSpots(line),
            color: primaryColors[lineIndex],
            barWidth: 3,
            isCurved: true,
          );
        }).toList(),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            drawBelowEverything: true,
            axisNameSize: deviceSize.width * 0.1,
            axisNameWidget: CustomDefaultTextStyle(
              text: widget.statistic.labelX,
              fontSize: AppSettings.fontSizeH4,
            ),
            sideTitles: SideTitles(
              interval: 1,
              showTitles: true,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: AxisSide.bottom,
                space: 4,
                child: CustomDefaultTextStyle(text: getWeekday(value.toInt(), true)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getHighestValueCeiled(List<Map<String, dynamic>> values) {
    double highestValue = 0;

    for (var map in values) {
      for (var entry in map.entries) {
        if (entry.value is num) {
          if (entry.value > highestValue) {
            highestValue = entry.value.toDouble();
          }
        }
      }
    }

    if (highestValue < 10) {
      return highestValue.ceilToDouble();
    }

    double power = 1;
    while (highestValue / power > 10) {
      power *= 10;
    }

    highestValue = (highestValue / power).ceilToDouble() * power;
    return highestValue;
  }

  List<FlSpot> buildSpots(Map<String, dynamic> line) {
    List<FlSpot> spots = [];

    for (int i = 0; i <= period - 1; i++) {
      if (line.containsKey(i.toString())) {
        spots.add(FlSpot(i.toDouble(), line[i.toString()].toDouble()));
      } else {
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }

    return spots;
  }

  BarChart buildBarChart(List<Map<String, dynamic>> values) {
    return BarChart(BarChartData());
  }

  PieChart buildPieChart(Size deviceSize, List<Map<String, dynamic>> values) {
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
        sections: values[0].entries.map((entry) {
          int index = values[0].keys.toList().indexOf(entry.key);
          bool isTouched = touchIndex == index;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: "${getWeekday(int.parse(entry.key), false)}\n (${entry.value})",
            titlePositionPercentageOffset: 0.7,
            showTitle: true,
            radius: isTouched ? deviceSize.width * 0.35 : deviceSize.width * 0.25,
            color: primaryColors[index],
            titleStyle: TextStyle(fontSize: isTouched ? AppSettings.fontSizeH4 : AppSettings.fontSize),
          );
        }).toList(),
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
              fontSize: fontSize,
            ),
            CustomDefaultTextStyle(
              text: text.substring(startIndex, endIndex),
              fontSize: fontSize,
            ),
            CustomDefaultTextStyle(
              text: endIndex < text.length ? text.substring(endIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
              fontSize: fontSize,
            ),
          ],
        );
      }
      return CustomDefaultTextStyle(
        text: text,
        color: AppSettings.font.withOpacity(0.5),
        fontSize: fontSize,
      );
    }
    return CustomDefaultTextStyle(
      text: text,
      fontSize: fontSize,
    );
  }
}
