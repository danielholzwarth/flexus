import 'dart:math';

import 'package:flutter/material.dart';
import 'package:app/resources/app_settings.dart';

class FlexusExerciseListTile extends StatefulWidget {
  final String? query;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool)? onChanged;

  const FlexusExerciseListTile({
    super.key,
    this.query,
    required this.title,
    this.subtitle = "",
    required this.value,
    this.onChanged,
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
          ? Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: AppSettings.fontSizeDescription,
              ),
            )
          : null,
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
        if (widget.onChanged != null) {
          widget.onChanged!(isChecked);
        }
      },
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: buildRandomImage(),
      ),
      trailing: Checkbox(
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

        return RichText(
          text: TextSpan(
            text: startIndex > 0 ? text.substring(0, startIndex) : "",
            style: TextStyle(
              fontSize: AppSettings.fontSize,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: text.substring(startIndex, endIndex),
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: AppSettings.font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: endIndex < text.length ? text.substring(endIndex) : "",
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }
      return RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: AppSettings.fontSize,
            color: Colors.grey,
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: AppSettings.fontSize,
          color: AppSettings.font,
        ),
      ),
    );
  }
}
