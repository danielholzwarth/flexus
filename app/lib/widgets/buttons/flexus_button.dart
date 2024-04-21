import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusButton extends StatelessWidget {
  final String text;
  final Function() function;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? width;

  const FlexusButton({
    super.key,
    required this.text,
    required this.function,
    this.backgroundColor,
    this.fontColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: width ?? deviceSize.width * 0.7,
      height: deviceSize.height * 0.08,
      child: ElevatedButton(
        onPressed: () => function(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor ?? AppSettings.background),
          elevation: MaterialStateProperty.all(AppSettings.elevation),
          shadowColor: null,
          overlayColor: null,
          surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
        ),
        child: CustomDefaultTextStyle(
          text: text,
          textAlign: TextAlign.center,
          color: fontColor ?? AppSettings.font,
          fontSize: AppSettings.fontSizeH4,
        ),
      ),
    );
  }
}
