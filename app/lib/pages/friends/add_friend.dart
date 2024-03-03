import 'package:app/pages/friends/show_qr.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final ScrollController scrollController = ScrollController();
  final userBox = Hive.box('userBox');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          buildAppBar(context, screenWidth),
        ],
      ),
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context, double screenWidth) {
    return FlexusSliverAppBar(
      title: Text(
        "Add Friend",
        style: TextStyle(color: AppSettings.font, fontSize: AppSettings.fontSizeTitle),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.qr_code_scanner,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const ShowQRPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
