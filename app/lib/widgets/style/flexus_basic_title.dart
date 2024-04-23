import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusBasicTitle extends StatelessWidget {
  final Size deviceSize;
  final String text;
  final bool hasPadding;

  const FlexusBasicTitle({
    super.key,
    required this.deviceSize,
    required this.text,
    this.hasPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: hasPadding ? deviceSize.height * 0.03 : 0,
        bottom: hasPadding ? deviceSize.height * 0.01 : 0,
      ),
      child: CustomDefaultTextStyle(
        text: text,
        fontWeight: FontWeight.bold,
        fontSize: AppSettings.fontSizeH3,
      ),
    );
  }
}
