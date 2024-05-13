import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusError extends StatelessWidget {
  final String? text;
  final Function()? func;

  const FlexusError({
    super.key,
    this.text,
    this.func,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomDefaultTextStyle(
          text: text != null && text != "null" ? "Error: $text" : "Error: Unknown",
          color: AppSettings.error,
        ),
        IconButton(
          onPressed: func,
          icon: FlexusDefaultIcon(
            iconData: Icons.refresh,
            iconColor: AppSettings.error,
          ),
        )
      ],
    );
  }
}
