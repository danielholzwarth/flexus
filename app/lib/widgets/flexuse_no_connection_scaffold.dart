import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class FlexusNoConnectionScaffold extends StatelessWidget {
  final String? title;
  const FlexusNoConnectionScaffold({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        slivers: [
          FlexusSliverAppBar(
            title: title != null
                ? CustomDefaultTextStyle(
                    text: title!,
                    fontSize: AppSettings.fontSizeH3,
                  )
                : null,
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlexusDefaultIcon(
                    iconData: Icons.wifi_off,
                    iconColor: AppSettings.error,
                  ),
                  SizedBox(height: AppSettings.screenHeight * 0.02),
                  CustomDefaultTextStyle(
                    text: "This feature requires Internet connection",
                    color: AppSettings.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
