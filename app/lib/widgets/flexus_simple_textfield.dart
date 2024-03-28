import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlexusTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String) onChanged;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;

  const FlexusTextFormField({
    super.key,
    required this.hintText,
    required this.textController,
    required this.onChanged,
    this.textInputType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      keyboardType: textInputType,
      controller: textController,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        focusColor: AppSettings.primary,
        hoverColor: AppSettings.primary,
        fillColor: AppSettings.primary,
        labelText: hintText,
        labelStyle: TextStyle(color: AppSettings.primary),
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 1)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 1)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppSettings.primary, width: 1)),
        hintStyle: TextStyle(
          decorationColor: AppSettings.primary,
          color: AppSettings.primary,
        ),
      ),
    );
  }
}
