import 'package:app/hive/exercise/exercise.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:app/resources/app_settings.dart';

class FlexusExerciseListTile extends StatefulWidget {
  final String? query;
  final Exercise exercise;
  final bool value;
  final Function()? onTap;
  final Function(bool)? onChanged;
  final bool isMultipleChoice;

  const FlexusExerciseListTile({
    super.key,
    this.query,
    required this.exercise,
    required this.value,
    this.onTap,
    this.onChanged,
    this.isMultipleChoice = true,
  });

  @override
  FlexusExerciseListTileState createState() => FlexusExerciseListTileState();
}

class FlexusExerciseListTileState extends State<FlexusExerciseListTile> {
  @override
  Widget build(BuildContext context) {
    bool isChecked = widget.value;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      title: highlightText(widget.exercise.name),
      subtitle: widget.exercise.typeID == 1
          ? CustomDefaultTextStyle(
              text: "Repetition",
              fontSize: AppSettings.fontSizeT2,
            )
          : CustomDefaultTextStyle(
              text: "Duration",
              fontSize: AppSettings.fontSizeT2,
            ),
      onTap: widget.onTap ??
          (widget.isMultipleChoice
              ? null
              // ? () {
              //     Navigator.push(
              //       context,
              //       PageTransition(
              //         type: PageTransitionType.fade,
              //         child: ExerciseExplanationPage(name: widget.exercise.name, exerciseID: widget.exercise.id),
              //       ),
              //     );
              //   }
              : () {
                  setState(() {
                    isChecked = !isChecked;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(isChecked);
                  }
                }),
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: buildLeading(),
      ),
      trailing: widget.isMultipleChoice
          ? Checkbox(
              activeColor: AppSettings.primary,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value!);
                }
                setState(() {
                  isChecked = value!;
                });
              },
              value: isChecked,
            )
          : null,
      // IconButton(
      //     onPressed: null,
      //     // () {
      //     //   Navigator.push(
      //     //     context,
      //     //     PageTransition(
      //     //       type: PageTransitionType.fade,
      //     //       child: ExerciseExplanationPage(name: widget.exercise.name, exerciseID: widget.exercise.id),
      //     //     ),
      //     //   );
      //     // },
      //     icon: FlexusDefaultIcon(
      //       iconData: Icons.info,
      //       iconColor: AppSettings.primaryShade80,
      //     ),
      //   ),
    );
  }

  Widget buildLeading() {
    return widget.exercise.typeID == 1
        ? FlexusDefaultIcon(
            iconData: Icons.repeat,
            iconSize: AppSettings.fontSizeH2,
          )
        : FlexusDefaultIcon(
            iconData: Icons.timer_outlined,
            iconSize: AppSettings.fontSizeH2,
          );
  }

  Widget highlightText(String text) {
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
