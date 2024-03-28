import 'package:flutter/material.dart';
import 'package:app/resources/app_settings.dart';

class FlexusExerciseListTile extends StatefulWidget {
  final String? query;
  final String title;
  final String subtitle;
  final Function(bool)? onChanged;

  const FlexusExerciseListTile({
    super.key,
    this.query,
    required this.title,
    this.subtitle = "",
    this.onChanged,
  });

  @override
  FlexusExerciseListTileState createState() => FlexusExerciseListTileState();
}

class FlexusExerciseListTileState extends State<FlexusExerciseListTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
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
