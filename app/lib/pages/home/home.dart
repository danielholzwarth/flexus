import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/user_account/user_account.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/pages/home/archive.dart';
import 'package:app/pages/profile/profile.dart';
import 'package:app/pages/sign_in/login.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/workouts_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_scrollbar.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
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
    return BlocBuilder(
      bloc: workoutBloc,
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
                        starttime: state.workoutOverviews[index].workout.starttime,
                        endtime: state.workoutOverviews[index].workout.endtime,
                        isArchived: state.workoutOverviews[index].workout.isArchived,
                        isStared: state.workoutOverviews[index].workout.isStared,
                        isPinned: state.workoutOverviews[index].workout.isPinned,
                      ),
                      planName: state.workoutOverviews[index].planName,
                      splitName: state.workoutOverviews[index].splitName,
                    ),
                    workoutBloc: workoutBloc,
                  );
                },
                childCount: state.workoutOverviews.length,
              ),
            );
          } else {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  'No workouts found',
                  style: TextStyle(fontSize: AppSettings.fontSize),
                ),
              ),
            );
          }
        } else if (state is WorkoutError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(fontSize: AppSettings.fontSize),
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
      icon: Icons.add,
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
                  icon: Icon(
                    Icons.person,
                    size: AppSettings.fontSizeTitle,
                  ),
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
        IconButton(
          icon: Icon(
            Icons.archive,
            size: AppSettings.fontSizeTitle,
          ),
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
          icon: Icon(
            Icons.menu_book,
            size: AppSettings.fontSizeTitle,
          ),
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
          icon: const Icon(Icons.search),
        )
      ],
    );
  }
}
