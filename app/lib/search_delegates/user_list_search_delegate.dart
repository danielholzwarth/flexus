import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_list_list_tile.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListCustomSearchDelegate extends SearchDelegate {
  final int listID;

  UserListCustomSearchDelegate({
    required this.listID,
  });

  ScrollController scrollController = ScrollController();
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
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(context);
  }

  Widget buildSearchResults(BuildContext context) {
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: true, keyword: query));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppSettings.background,
        body: BlocBuilder(
          bloc: userAccountBloc,
          builder: (context, state) {
            if (state is UserAccountsLoaded) {
              if (state.userAccounts.isNotEmpty) {
                return FlexusScrollBar(
                  scrollController: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return FlexusUserListListTile(
                        userAccount: state.userAccounts[index],
                        listID: listID,
                        query: query,
                        key: UniqueKey(),
                      );
                    },
                    itemCount: state.userAccounts.length,
                  ),
                );
              } else {
                return const Center(child: CustomDefaultTextStyle(text: "No users found"));
              }
            } else {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            }
          },
        ),
      ),
    );
  }
}
