import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
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
                ? Text(
                    title!,
                    style: TextStyle(
                      color: AppSettings.font,
                      fontSize: AppSettings.fontSizeH3,
                    ),
                  )
                : null,
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: AppSettings.fontSizeH3,
                    color: AppSettings.error,
                  ),
                  SizedBox(height: AppSettings.screenHeight * 0.02),
                  Text(
                    "This feature requires Internet connection",
                    style: TextStyle(
                      color: AppSettings.error,
                      fontSize: AppSettings.fontSize,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
