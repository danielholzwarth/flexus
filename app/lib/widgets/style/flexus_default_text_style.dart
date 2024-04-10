import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class CustomDefaultTextStyle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final Color? color;
  final double? fontSize;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;

  const CustomDefaultTextStyle({
    super.key,
    required this.text,
    this.textAlign,
    this.decoration,
    this.color,
    this.fontSize,
    this.overflow,
    this.fontWeight,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: TextStyle(
        decoration: decoration,
        color: color ?? AppSettings.font,
        fontSize: fontSize ?? AppSettings.fontSize,
        overflow: overflow ?? TextOverflow.clip,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );
  }
}
