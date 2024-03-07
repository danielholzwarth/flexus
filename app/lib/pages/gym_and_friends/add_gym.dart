import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:flutter/material.dart';
class AddGymPage extends StatefulWidget {
  const AddGymPage({super.key});

  @override
  State<AddGymPage> createState() => _AddGymPageState();
}

class _AddGymPageState extends State<AddGymPage> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          buildAppBar(context),
          buildSearchBar(),
          //buildUserAccounts(),
        ],
      ),
    );
  }

  SliverAppBar buildSearchBar() {
    return SliverAppBar(
      surfaceTintColor: AppSettings.background,
      title: Container(
        height: AppSettings.screenHeight * 0.06,
        width: AppSettings.screenWidth * 0.8,
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
          onChanged: (value) {},
        ),
      ),
      centerTitle: true,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppSettings.background,
      foregroundColor: AppSettings.font,
      toolbarHeight: AppSettings.screenHeight * 0.07,
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      isPinned: true,
      title: Text(
        "Add Gym",
        style: TextStyle(color: AppSettings.font, fontSize: AppSettings.fontSizeTitle),
      ),
    );
  }
}
