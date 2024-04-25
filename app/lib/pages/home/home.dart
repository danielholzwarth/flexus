import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/pages/home/archive.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/pages/sign_in/login.dart';
import 'package:app/pages/workout/start_workout.dart';
import 'package:app/pages/plan/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/workouts_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  final bool isStartup;
  const HomePage({
    super.key,
    this.isStartup = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();
  bool isArchiveVisible = false;
  bool isSearch = false;
  final TextEditingController searchController = TextEditingController();
  final WorkoutBloc workoutBloc = WorkoutBloc();
  final UserAccountBloc userAccountBloc = UserAccountBloc();
  final userBox = Hive.box('userBox');

  @override
  void initState() {
    workoutBloc.add(GetWorkout());
    UserAccount userAccount = userBox.get("userAccount");
    userAccountBloc.add(GetUserAccount(userAccountID: userAccount.id));
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
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: FlexusScrollBar(
        scrollController: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            buildAppBar(context, userAccountBloc),
            buildWorkouts(),
          ],
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  Widget buildWorkouts() {
    return BlocConsumer(
      bloc: workoutBloc,
      listener: (context, state) {
        if (state is WorkoutLoaded) {
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is WorkoutLoaded) {
          if (state.workoutOverviews.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusWorkoutListTile(
                    key: Key("workout${state.workoutOverviews[index].workout.id}"),
                    workoutOverview: WorkoutOverview(
                      workout: Workout(
                        id: state.workoutOverviews[index].workout.id,
                        userAccountID: state.workoutOverviews[index].workout.userAccountID,
                        createdAt: state.workoutOverviews[index].workout.createdAt,
                        starttime: state.workoutOverviews[index].workout.starttime,
                        endtime: state.workoutOverviews[index].workout.endtime,
                        isArchived: state.workoutOverviews[index].workout.isArchived,
                        isStared: state.workoutOverviews[index].workout.isStared,
                        isPinned: state.workoutOverviews[index].workout.isPinned,
                      ),
                      planName: state.workoutOverviews[index].planName,
                      splitName: state.workoutOverviews[index].splitName,
                      bestLiftCount: state.workoutOverviews[index].bestLiftCount,
                    ),
                    workoutBloc: workoutBloc,
                  );
                },
                childCount: state.workoutOverviews.length,
              ),
            );
          } else {
            return const SliverFillRemaining(
              child: Center(
                child: CustomDefaultTextStyle(
                  text: 'No workouts found',
                ),
              ),
            );
          }
        } else if (state is WorkoutError) {
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

  FlexusFloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FlexusFloatingActionButton(
      onPressed: () async {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const StartWorkoutPage(),
          ),
        );
      },
      icon: Icons.fitness_center,
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context, UserAccountBloc userAccountBloc) {
    return FlexusSliverAppBar(
      isPinned: false,
      leading: SizedBox(
        child: BlocBuilder(
          bloc: userAccountBloc,
          builder: (context, state) {
            if (state is UserAccountLoaded) {
              if (state.userAccount.profilePicture != null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: ProfilePage(userID: state.userAccount.id),
                        ),
                      ).then((value) {
                        userAccountBloc.add(GetUserAccount(userAccountID: state.userAccount.id));
                      });
                    },
                    child: CircleAvatar(
                      radius: AppSettings.fontSize,
                      backgroundImage: MemoryImage(state.userAccount.profilePicture!),
                    ),
                  ),
                );
              } else {
                return IconButton(
                  icon: const FlexusDefaultIcon(iconData: Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: ProfilePage(userID: state.userAccount.id),
                      ),
                    ).then((value) {
                      userAccountBloc.add(GetUserAccount(userAccountID: state.userAccount.id));
                    });
                  },
                );
              }
            } else {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            }
          },
        ),
      ),
      actions: [
        Visibility(
          visible: AppSettings.isTokenExpired,
          child: IconButton(
            icon: const FlexusDefaultIcon(iconData: Icons.sync),
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
            icon: FlexusDefaultIcon(
              iconData: Icons.wifi_off,
              iconColor: AppSettings.error,
            ),
            onPressed: () {},
          ),
        ),
        IconButton(
          icon: const FlexusDefaultIcon(iconData: Icons.archive),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const ArchivePage(),
              ),
            ).then((value) => workoutBloc.add(GetWorkout()));
          },
        ),
        IconButton(
          icon: const FlexusDefaultIcon(iconData: Icons.menu_book),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const PlanPage(),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () async {
            await showSearch(context: context, delegate: WorkoutsCustomSearchDelegate(isArchived: false));
            workoutBloc.add(GetWorkout());
          },
          icon: const FlexusDefaultIcon(iconData: Icons.search),
        )
      ],
    );
  }
}
