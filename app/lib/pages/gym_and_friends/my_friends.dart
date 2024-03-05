import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_search_textfield.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class MyFriendsPage extends StatefulWidget {
  const MyFriendsPage({super.key});

  @override
  State<MyFriendsPage> createState() => _MyFriendsPageState();
}

class _MyFriendsPageState extends State<MyFriendsPage> {
  final ScrollController scrollController = ScrollController();
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  final userBox = Hive.box('userBox');

  @override
  void initState() {
    userAccountBloc.add(LoadUserAccounts(isFriends: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          _buildFlexusSliverAppBar(context, screenWidth),
          buildUserAccounts(),
        ],
      ),
    );
  }

  FlexusSliverAppBar _buildFlexusSliverAppBar(BuildContext context, double screenWidth) {
    return isSearch ? buildSearchBar(context) : buildAppBar(context, screenWidth);
  }

  FlexusSliverAppBar buildSearchBar(BuildContext context) {
    return FlexusSliverAppBar(
      title: FlexusSearchTextField(
        hintText: "Search...",
        onChanged: (String newValue) {
          userAccountBloc.add(LoadUserAccounts(keyword: searchController.text, isFriends: true));
        },
        textController: searchController,
        suffixOnPressed: () {
          setState(() {
            searchController.clear();
            isSearch = false;
            userAccountBloc.add(LoadUserAccounts(isFriends: true));
          });
        },
      ),
    );
  }

  Widget buildUserAccounts() {
    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoading) {
          return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
        } else if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusUserAccountListTile(
                    userAccount: UserAccount(
                      id: state.userAccounts[index].id,
                      username: state.userAccounts[index].username,
                      name: state.userAccounts[index].name,
                      createdAt: state.userAccounts[index].createdAt,
                      level: state.userAccounts[index].level,
                      profilePicture: state.userAccounts[index].profilePicture,
                    ),
                  );
                },
                childCount: state.userAccounts.length,
              ),
            );
          } else {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  'No friends found',
                  style: TextStyle(fontSize: AppSettings.fontSize),
                ),
              ),
            );
          }
        } else if (state is UserAccountsError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Error loading workouts',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        } else {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Error XYZ',
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
            ),
          );
        }
      },
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context, double screenWidth) {
    return FlexusSliverAppBar(
      isPinned: true,
      title: Text(
        "My Friends",
        style: TextStyle(color: AppSettings.font, fontSize: AppSettings.fontSizeTitle),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            setState(() {
              isSearch = true;
            });
          },
        ),
      ],
    );
  }
}
