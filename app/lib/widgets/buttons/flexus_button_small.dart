import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusButtonSmall extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final Color? fontColor;
  final double? width;

  const FlexusButtonSmall({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return ElevatedButton(
      autofocus: true,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(AppSettings.background),
        surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
        overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
        foregroundColor: MaterialStateProperty.all(AppSettings.primary),
        fixedSize: MaterialStateProperty.all(Size.fromWidth(width ?? deviceSize.width * 0.4)),
      ),
      onPressed: onPressed,
      child: CustomDefaultTextStyle(text: text, color: fontColor),
    );
  }
}
