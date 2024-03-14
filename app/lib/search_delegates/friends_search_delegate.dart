import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/list_tiles/flexus_user_account_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsCustomSearchDelegate extends SearchDelegate {
  final bool? isFriend;
  final bool? hasRequest;

  FriendsCustomSearchDelegate({
    this.isFriend,
    this.hasRequest,
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
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: isFriend, hasRequest: hasRequest, keyword: query));

    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: FlexusScrollBar(
                scrollController: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return FlexusUserAccountListTile(
                      userAccount: state.userAccounts[index],
                      query: query,
                    );
                  },
                  itemCount: state.userAccounts.length,
                ),
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
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    userAccountBloc.add(GetUserAccountsFriendsSearch(isFriend: isFriend, hasRequest: hasRequest, keyword: query));

    return BlocBuilder(
      bloc: userAccountBloc,
      builder: (context, state) {
        if (state is UserAccountsLoaded) {
          if (state.userAccounts.isNotEmpty) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: FlexusScrollBar(
                scrollController: scrollController,
                child: ListView.builder(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    return FlexusUserAccountListTile(
                      userAccount: state.userAccounts[index],
                      query: query,
                    );
                  },
                  itemCount: state.userAccounts.length,
                ),
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
            body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
          );
        }
      },
    );
  }
}
