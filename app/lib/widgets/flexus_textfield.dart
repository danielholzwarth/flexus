import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController textController;
  final Function(String) onChanged;
  final TextInputType textInputType;
  final bool isObscure;
  final Color? backgroundColor;
  final Color? fontColor;
  final Color? hintColor;
  final Color? borderColor;
  final double? width;

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
    this.width,
  });

  @override
  State<FlexusTextField> createState() => _FlexusTextFieldState();
}

class _FlexusTextFieldState extends State<FlexusTextField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: widget.width ?? deviceSize.width * 0.7,
        height: deviceSize.height * 0.08,
        child: Center(
          child: TextField(
            keyboardType: widget.textInputType,
            obscureText: widget.isObscure ? _isObscure : false,
            onChanged: widget.onChanged,
            textAlign: TextAlign.center,
            controller: widget.textController,
            cursorColor: widget.fontColor ?? AppSettings.font,
            style: TextStyle(
              color: widget.fontColor ?? AppSettings.font,
              fontSize: AppSettings.fontSize,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: widget.hintColor?.withOpacity(0.5) ?? AppSettings.font.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              suffixIcon: widget.isObscure
                  ? IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: widget.hintColor ?? AppSettings.font,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
