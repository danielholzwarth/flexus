import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/pages/friends/show_qr.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/friends_search_delegate.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexuse_no_connection_scaffold.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final ScrollController scrollController = ScrollController();
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  final userBox = Hive.box('userBox');

  @override
  void initState() {
    userAccountBloc.add(GetUserAccounts(isFriend: true, hasRequest: true));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppSettings.hasConnection) {
      return Scaffold(
        backgroundColor: AppSettings.background,
        body: FlexusScrollBar(
          scrollController: scrollController,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              buildAppBar(context),
              buildUserAccounts(),
            ],
          ),
        ),
      );
    } else {
      return const FlexusNoConnectionScaffold(
        title: "My Friends",
      );
    }
  }

  Widget buildUserAccounts() {
    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusUserAccountListTile(
                    key: UniqueKey(),
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
            return const SliverFillRemaining(
              child: Center(
                child: CustomDefaultTextStyle(
                  text: 'No friends found',
                ),
              ),
            );
          }
        } else if (state is UserAccountsError) {
          return SliverFillRemaining(
            child: Center(
              child: CustomDefaultTextStyle(
                text: 'Error: ${state.error}',
              ),
            ),
          );
        } else {
          return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
        }
      },
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      isPinned: true,
      title: CustomDefaultTextStyle(
        text: "Friends",
        fontSize: AppSettings.fontSizeH3,
      ),
      actions: [
        IconButton(
          icon: const FlexusDefaultIcon(iconData: Icons.qr_code_scanner),
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
          icon: const FlexusDefaultIcon(iconData: Icons.search),
          onPressed: () async {
            await showSearch(context: context, delegate: FriendSearchDelegate(isFriend: false, hasRequest: false));
            userAccountBloc.add(GetUserAccounts(isFriend: true, hasRequest: true));
          },
        ),
      ],
    );
  }
}
