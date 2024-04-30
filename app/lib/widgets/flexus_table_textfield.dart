import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusTableTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String) onChanged;
  final TextInputType textInputType;
  final TextAlign textAlign;
  final bool isObscure;
  final Color? fontColor;
  final Color? hintColor;

  const FlexusTableTextField({
    super.key,
    required this.hintText,
    required this.textController,
    required this.onChanged,
    this.textInputType = TextInputType.text,
    this.textAlign = TextAlign.center,
    this.isObscure = false,
    this.fontColor,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: deviceSize.width * 0.2,
      child: TextField(
        keyboardType: textInputType,
        obscureText: isObscure,
        onChanged: onChanged,
        textAlign: textAlign,
        controller: textController,
        cursorColor: fontColor ?? AppSettings.font,
        style: TextStyle(
          color: fontColor ?? AppSettings.font,
          fontSize: AppSettings.fontSize,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor?.withOpacity(0.5) ?? AppSettings.font.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.02, vertical: deviceSize.width * 0.01),
        ),
      ),
    );
  }
}
