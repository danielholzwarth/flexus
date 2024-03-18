import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';

class FlexusNoConnectionScaffold extends StatelessWidget {
  const FlexusNoConnectionScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: AppSettings.fontSizeTitle,
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
