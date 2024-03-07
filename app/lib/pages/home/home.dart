import 'package:app/bloc/user_account_bloc/user_account_bloc.dart';
import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/user_account.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/home/archive.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/pages/login/login.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_search_textfield.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/list_tiles/flexus_workout_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  bool isTokenExpired = false;

  @override
  void initState() {
    super.initState();
    workoutBloc.add(GetWorkout());
    UserAccount userAccount = userBox.get("userAccount");
    userAccountBloc.add(GetUserAccount(userAccountID: userAccount.id));
  }

  @override
  Widget build(BuildContext context) {
    isTokenExpired = JwtDecoder.isExpired(userBox.get("flexusjwt"));
    return Scaffold(
      backgroundColor: AppSettings.background,
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          _buildFlexusSliverAppBar(context),
          buildWorkouts(),
        ],
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  Widget buildWorkouts() {
    return BlocBuilder(
      bloc: workoutBloc,
      builder: (context, state) {
        if (state is WorkoutLoading || state is WorkoutSearching || state is WorkoutUpdating || state is WorkoutDeleting) {
          return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
        } else if (state is WorkoutLoaded) {
          if (state.workoutOverviews.isNotEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return FlexusWorkoutListTile(
                    workoutOverview: WorkoutOverview(
                      workout: Workout(
                        id: state.workoutOverviews[index].workout.id,
                        userAccountID: state.workoutOverviews[index].workout.userAccountID,
                        starttime: state.workoutOverviews[index].workout.starttime,
                        endtime: state.workoutOverviews[index].workout.endtime,
                        isArchived: false,
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

  FlexusSliverAppBar _buildFlexusSliverAppBar(BuildContext context) {
    return isSearch ? buildSearchBar(context) : buildAppBar(context, userAccountBloc);
  }

  FlexusSliverAppBar buildSearchBar(BuildContext context) {
    return FlexusSliverAppBar(
      title: FlexusSearchTextField(
        hintText: "Search...",
        onChanged: (String newValue) {
          workoutBloc.add(GetSearchWorkout(keyWord: searchController.text));
        },
        textController: searchController,
        suffixOnPressed: () {
          setState(() {
            searchController.text = "";
            isSearch = false;
            workoutBloc.add(GetWorkout());
          });
        },
      ),
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context, UserAccountBloc userAccountBloc) {
    return FlexusSliverAppBar(
      isPinned: false,
      leading: SizedBox(
        child: BlocBuilder(
          bloc: userAccountBloc,
          builder: (context, state) {
            if (state is UserAccountLoading) {
              return Center(child: CircularProgressIndicator(color: AppSettings.primary));
            } else if (state is UserAccountLoaded) {
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
              return Icon(
                Icons.error,
                size: AppSettings.fontSizeTitle,
              );
            }
          },
        ),
      ),
      actions: [
        Visibility(
          visible: isTokenExpired,
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
          icon: Icon(
            Icons.search,
            size: AppSettings.fontSizeTitle,
          ),
          onPressed: () {
            setState(() {
              isArchiveVisible = false;
              isSearch = true;
              workoutBloc.add(GetSearchWorkout());
            });
          },
        ),
      ],
    );
  }
}
