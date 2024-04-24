import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ViewWorkoutPage extends StatefulWidget {
  final int workoutID;

  const ViewWorkoutPage({
    super.key,
    this.workoutID = -1,
  });

  @override
  State<ViewWorkoutPage> createState() => _ViewWorkoutPageState();
}

class _ViewWorkoutPageState extends State<ViewWorkoutPage> {
  @override
  void initState() {
    // Get Workout Details
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: CustomDefaultTextStyle(
          text: 'Workout Name (${widget.workoutID})',
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildStats(deviceSize),
            SizedBox(height: deviceSize.height * 0.03),
            buildExercises(deviceSize),
          ],
        ),
      ),
    );
  }

  Widget buildStats(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: FlexusBasicTitle(
            deviceSize: deviceSize,
            text: "Stats",
            hasPadding: false,
          ),
        ),
        DataTable(
          dataRowMinHeight: deviceSize.height * 0.02,
          dataRowMaxHeight: deviceSize.height * 0.05,
          headingRowHeight: deviceSize.height * 0.02,
          columns: const [
            DataColumn(label: CustomDefaultTextStyle(text: '')),
            DataColumn(label: CustomDefaultTextStyle(text: '')),
          ],
          rows: [
            buildDataRow("Date", "24.04.2024"),
            const DataRow(
              cells: [
                DataCell(CustomDefaultTextStyle(text: "Gym")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomDefaultTextStyle(text: "Energym Öhringen"),
                    ],
                  ),
                ),
              ],
            ),
            const DataRow(
              cells: [
                DataCell(CustomDefaultTextStyle(text: "Duration")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(child: CustomDefaultTextStyle(text: "1h 35min")),
                    ],
                  ),
                ),
              ],
            ),
            const DataRow(
              cells: [
                DataCell(CustomDefaultTextStyle(text: "Total moved weight")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomDefaultTextStyle(text: "12.204kg"),
                    ],
                  ),
                ),
              ],
            ),
            const DataRow(
              cells: [
                DataCell(CustomDefaultTextStyle(text: "New Personal Bests")),
                DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomDefaultTextStyle(text: "3"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildExercises(Size deviceSize) {
    int exerciseCount = 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: FlexusBasicTitle(
            deviceSize: deviceSize,
            text: "Exercises",
            hasPadding: false,
          ),
        ),
        for (int i = 0; i <= exerciseCount; i++)
          DataTable(
            dataRowMinHeight: deviceSize.height * 0.02,
            dataRowMaxHeight: deviceSize.height * 0.05,
            headingRowHeight: deviceSize.height * 0.04,
            columns: [
              DataColumn(
                label: CustomDefaultTextStyle(
                  text: '${i + 1}. Butterfly',
                  fontWeight: FontWeight.w600,
                  fontSize: AppSettings.fontSizeH4,
                ),
              ),
              const DataColumn(label: CustomDefaultTextStyle(text: '')),
              const DataColumn(label: CustomDefaultTextStyle(text: '')),
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(CustomDefaultTextStyle(text: "Set 1")),
                  const DataCell(CustomDefaultTextStyle(text: "8 Reps á 60kg")),
                  DataCell(Container()),
                ],
              ),
              DataRow(
                cells: [
                  const DataCell(CustomDefaultTextStyle(text: "Set 2")),
                  const DataCell(CustomDefaultTextStyle(text: "8 Reps á 60kg")),
                  DataCell(Container()),
                ],
              ),
              const DataRow(
                cells: [
                  DataCell(CustomDefaultTextStyle(text: "Set 3")),
                  DataCell(CustomDefaultTextStyle(text: "8 Reps á 60kg")),
                  DataCell(FlexusDefaultIcon(iconData: Icons.emoji_events)),
                ],
              ),
            ],
          ),
      ],
    );
  }

  DataRow buildDataRow(String first, String second) {
    return DataRow(
      cells: [
        DataCell(CustomDefaultTextStyle(text: first)),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: CustomDefaultTextStyle(text: second),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
