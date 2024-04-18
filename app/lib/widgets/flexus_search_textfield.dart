import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:flutter/material.dart';

class FlexusSearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String) onChanged;
  final Function() suffixOnPressed;

  final Color? fontColor;
  final Color? hintColor;

  const FlexusSearchTextField({
    super.key,
    required this.hintText,
    required this.textController,
    required this.onChanged,
    this.fontColor,
    this.hintColor,
    required this.suffixOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return SizedBox(
      width: deviceSize.width * 0.8,
      child: TextField(
        autofocus: true,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        controller: textController,
        cursorColor: fontColor ?? AppSettings.font,
        style: TextStyle(
          color: fontColor ?? AppSettings.font,
          fontSize: AppSettings.fontSize,
        ),
        decoration: InputDecoration(
          border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 2)),
          prefixIcon: const FlexusDefaultIcon(iconData: Icons.search),
          suffixIcon: IconButton(
            icon: const FlexusDefaultIcon(iconData: Icons.close),
            onPressed: suffixOnPressed,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor?.withOpacity(0.5) ?? AppSettings.font.withOpacity(0.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }
}
