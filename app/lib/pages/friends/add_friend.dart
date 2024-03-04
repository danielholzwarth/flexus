import 'package:app/hive/user_account.dart';
import 'package:app/pages/friends/show_qr.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexus_user_account_list_tile.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          buildAppBar(context, screenWidth),
          buildSearchBar(screenHeight, screenWidth),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return FlexusUserAccountListTile(
                  userAccount: UserAccount(id: index, username: "username", name: "name", createdAt: DateTime.now(), level: index),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar buildSearchBar(double screenHeight, double screenWidth) {
    return SliverAppBar(
      surfaceTintColor: AppSettings.background,
      title: Container(
        height: screenHeight * 0.06,
        width: screenWidth * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: AppSettings.primaryShade48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: AppSettings.font),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppSettings.font),
          ),
        ),
      ),
      centerTitle: true,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      toolbarHeight: screenHeight * 0.07,
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context, double screenWidth) {
    return FlexusSliverAppBar(
      isPinned: true,
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
