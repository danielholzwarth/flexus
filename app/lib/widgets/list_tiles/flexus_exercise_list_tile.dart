import 'dart:math';

import 'package:app/pages/workout/exercise_explanation.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:app/resources/app_settings.dart';
import 'package:page_transition/page_transition.dart';

class FlexusExerciseListTile extends StatefulWidget {
  final String? query;
  final String title;
  final String subtitle;
  final bool value;
  final Function()? onTap;
  final Function(bool)? onChanged;
  final bool isMultipleChoice;
  final int exerciseID;

  const FlexusExerciseListTile({
    super.key,
    this.query,
    required this.title,
    this.subtitle = "",
    required this.value,
    this.onTap,
    this.onChanged,
    this.isMultipleChoice = true,
    required this.exerciseID,
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
      title: highlightText(widget.title),
      subtitle: widget.subtitle.isNotEmpty
          ? CustomDefaultTextStyle(
              text: widget.subtitle,
              fontSize: AppSettings.fontSizeT2,
            )
          : null,
      onTap: widget.onTap ??
          (widget.isMultipleChoice
              ? () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: ExerciseExplanationPage(exerciseID: widget.exerciseID),
                    ),
                  );
                }
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
        child: buildRandomImage(),
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
          : IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ExerciseExplanationPage(exerciseID: widget.exerciseID),
                  ),
                );
              },
              icon: FlexusDefaultIcon(
                iconData: Icons.info,
                iconColor: AppSettings.primaryShade80,
              ),
            ),
    );
  }

  Widget buildRandomImage() {
    int randomNumber = Random().nextInt(4);
    return Image.network(
      randomNumber == 0
          ? "https://cdn-icons-png.flaticon.com/128/7922/7922281.png"
          : randomNumber == 1
              ? "https://cdn-icons-png.flaticon.com/128/2112/2112238.png"
              : randomNumber == 2
                  ? "https://cdn-icons-png.flaticon.com/128/7922/7922186.png"
                  : "https://cdn-icons-png.flaticon.com/128/2382/2382633.png",
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
