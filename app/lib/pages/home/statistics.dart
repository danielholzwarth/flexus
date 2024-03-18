import 'package:app/pages/sign_in/login.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        backgroundColor: AppSettings.background,
        title: const Text('StatisticsPage'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Visibility(
              visible: AppSettings.isTokenExpired,
              child: IconButton(
                icon: Icon(
                  Icons.sync,
                  size: AppSettings.fontSizeTitle,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: const LoginPage(),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: !AppSettings.hasConnection,
              child: IconButton(
                icon: Icon(
                  Icons.wifi_off,
                  size: AppSettings.fontSizeTitle,
                  color: AppSettings.error,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
