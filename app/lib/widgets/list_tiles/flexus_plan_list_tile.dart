import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:app/resources/app_settings.dart';

class FlexusPlanListTile extends StatefulWidget {
  final String? query;
  final String title;
  final Widget subtitle;
  final Function()? onPressed;

  const FlexusPlanListTile({
    super.key,
    this.query,
    required this.title,
    this.subtitle = const SizedBox(),
    this.onPressed,
  });

  @override
  FlexusPlanListTileState createState() => FlexusPlanListTileState();
}

class FlexusPlanListTileState extends State<FlexusPlanListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      title: highlightText(widget.title),
      onTap: widget.onPressed,
      subtitle: widget.subtitle,
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
