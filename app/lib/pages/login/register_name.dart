import 'package:app/resources/app_colors.dart';
import 'package:app/widgets/flexus_button.dart';
import 'package:app/widgets/flexus_gradient_container.dart';
import 'package:flutter/material.dart';

class RegisterNamePage extends StatelessWidget {
  const RegisterNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlexusGradientContainer(
      topColor: AppColors.startUp,
      bottomColor: AppColors.primary,
      child: const Column(
        children: [
          SizedBox(height: 100),
          FlexusButton(text: "asd", route: "/home"),
        ],
      ),
    );
  }
}
