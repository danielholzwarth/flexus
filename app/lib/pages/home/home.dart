import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/home/profile.dart';
import 'package:app/pages/login/login.dart';
import 'package:app/pages/workout_documentation/start_workout.dart';
import 'package:app/pages/workoutplan_creation/plan.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/flexus_archive_sliver_appbar.dart';
import 'package:app/widgets/flexus_bottom_navigation_bar.dart';
import 'package:app/widgets/flexus_floating_action_button.dart';
import 'package:app/widgets/flexus_search_textfield.dart';
import 'package:app/widgets/flexus_sliver_appbar.dart';
import 'package:app/widgets/flexus_workout_list_tile.dart';
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
  final userBox = Hive.box('userBox');
  bool isTokenExpired = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    workoutBloc.add(LoadWorkout());
  }

  void scrollListener() {
    if (scrollController.offset == 0) {
      setState(() {
        isArchiveVisible = true;
      });
    } else {
      setState(() {
        isArchiveVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isTokenExpired = JwtDecoder.isExpired(userBox.get("flexusjwt"));
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          _buildFlexusSliverAppBar(context),
          SliverVisibility(
            sliver: const FlexusArchiveSliverAppBar(),
            visible: isArchiveVisible,
          ),
          BlocConsumer(
              bloc: workoutBloc,
              listener: (context, state) {
                if (state is WorkoutLoaded) {}
              },
              builder: (context, state) {
                if (state is WorkoutLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Loading',
                        style: TextStyle(fontSize: AppSettings.fontSize),
                      ),
                    ),
                  );
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
              }),
        ],
      ),
      floatingActionButton: FlexusFloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const StartWorkoutPage(),
            ),
          );
        },
      ),
      bottomNavigationBar: FlexusBottomNavigationBar(scrollController: scrollController),
    );
  }

  FlexusSliverAppBar _buildFlexusSliverAppBar(BuildContext context) {
    return isSearch ? buildSearchBar(context) : buildAppBar(context);
  }

  FlexusSliverAppBar buildSearchBar(BuildContext context) {
    return FlexusSliverAppBar(
      title: FlexusSearchTextField(
        hintText: "Search...",
        onChanged: (String newValue) {
          workoutBloc.add(LoadWorkout(isSearch: true, keyWord: searchController.text));
        },
        textController: searchController,
        suffixOnPressed: () {
          setState(() {
            searchController.text = "";
            isSearch = false;
            workoutBloc.add(LoadWorkout());
          });
        },
      ),
    );
  }

  FlexusSliverAppBar buildAppBar(BuildContext context) {
    return FlexusSliverAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.person,
          size: AppSettings.fontSizeTitle,
        ),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.leftToRight,
              child: const ProfilePage(),
            ),
          );
        },
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
              workoutBloc.add(LoadWorkout(isSearch: true));
            });
          },
        ),
      ],
    );
  }
}
