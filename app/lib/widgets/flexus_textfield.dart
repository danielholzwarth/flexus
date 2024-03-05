import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String) onChanged;
  final TextInputType textInputType;
  final bool isObscure;
  final Color? backgroundColor;
  final Color? fontColor;
  final Color? hintColor;
  final Color? borderColor;

  const FlexusTextField({
    super.key,
    required this.hintText,
    required this.textController,
    required this.onChanged,
    this.textInputType = TextInputType.text,
    this.isObscure = false,
    this.backgroundColor,
    this.fontColor,
    this.hintColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: AppSettings.screenWidth * 0.7,
        height: AppSettings.screenHeight * 0.08,
        child: Center(
          child: TextField(
            obscureText: isObscure,
            onChanged: onChanged,
            textAlign: TextAlign.center,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
        ),
      ),
    );
  }
}
