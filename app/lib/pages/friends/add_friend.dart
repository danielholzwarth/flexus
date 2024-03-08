import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/pages/friends/show_qr.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final ScrollController scrollController = ScrollController();
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final userBox = Hive.box('userBox');

  @override
  void initState() {
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          buildAppBar(context),
          buildUserAccounts(),
        ],
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
                  'No user found',
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

  FlexusSliverAppBar buildAppBar(BuildContext context) {
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
        IconButton(
          icon: Icon(
            Icons.person_add,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            showSearch(context: context, delegate: CustomSearchDelegate());
          },
        ),
      ],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  UserAccountBloc userAccountBloc = UserAccountBloc();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: false, keyword: query));

    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoading) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: ListView.builder(
                itemBuilder: (context, index) {
                  return FlexusUserAccountListTile(
                    userAccount: state.userAccounts[index],
                    query: query,
                  );
                },
                itemCount: state.userAccounts.length,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: const Center(
                child: Text("No users found"),
              ),
            );
          }
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: const Center(
              child: Text("Error"),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: false, keyword: query));

    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoading) {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        } else if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: ListView.builder(
                itemBuilder: (context, index) {
                  return FlexusUserAccountListTile(
                    userAccount: state.userAccounts[index],
                    query: query,
                  );
                },
                itemCount: state.userAccounts.length,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: const Center(
                child: Text("No users found"),
              ),
            );
          }
        } else {
          return Scaffold(
            backgroundColor: AppSettings.background,
            body: const Center(
              child: Text("Error"),
            ),
          );
        }
      },
    );
  }
}
