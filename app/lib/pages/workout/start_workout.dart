import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/current_plan.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/pages/workout/document_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/my_gym_search_delegate.dart';
import 'package:app/search_delegates/plan_search_delegate.dart';
import 'package:app/search_delegates/split_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class StartWorkoutPage extends StatefulWidget {
  const StartWorkoutPage({
    super.key,
    this.workout,
  });
  final Workout? workout;

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {
  final userBox = Hive.box('userBox');
  final WorkoutBloc workoutBloc = WorkoutBloc();

  Gym? currentGym;
  CurrentPlan? currentPlan;

  @override
  void initState() {
    super.initState();
    if (AppSettings.hasConnection) {
      if (widget.workout != null) {
        workoutBloc.add(GetWorkoutDetails(workoutID: widget.workout!.id));
      } else {
        currentGym = userBox.get("currentGym");
      }
    }

    currentPlan = userBox.get("currentPlan");
    if (currentPlan != null) {
      CurrentPlan oldPlan = CurrentPlan.clone(currentPlan!);

      if (currentPlan!.currentSplit == currentPlan!.splits.length - 1) {
        currentPlan!.currentSplit = 0;
      } else {
        currentPlan!.currentSplit += 1;
      }
      userBox.put("currentPlan", oldPlan);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: buildAppBar(),
      body: BlocConsumer(
        bloc: workoutBloc,
        listener: (context, state) {
          if (state is WorkoutCreated || state is WorkoutsLoaded) {
            userBox.put("currentGym", currentGym);
            userBox.put("currentPlan", currentPlan);

            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: DocumentWorkoutPage(
                  gym: currentGym,
                  currentPlan: currentPlan,
                ),
              ),
            );
          }

          if (state is WorkoutDetailsLoaded) {
            currentGym = state.workoutDetails.gym;
          }

          if (state is WorkoutError) {
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: state.error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: AppSettings.error,
              textColor: AppSettings.fontV1,
              fontSize: AppSettings.fontSize,
            );
          }
        },
        builder: (context, state) {
          if (state is WorkoutCreating || state is WorkoutCreated || state is WorkoutDetailsLoading) {
            return Scaffold(body: Center(child: CircularProgressIndicator(color: AppSettings.primary)));
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildGym(context, deviceSize),
                    buildPlan(context, deviceSize),
                    buildSplit(context, deviceSize),
                    SizedBox(height: deviceSize.height * 0.2),
                    buildStart(context, deviceSize),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: CustomDefaultTextStyle(
        text: "Start Workout",
        fontSize: AppSettings.fontSizeH3,
      ),
      centerTitle: true,
      backgroundColor: AppSettings.background,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              currentGym = null;
              currentPlan = null;
            });
          },
          icon: FlexusDefaultIcon(
            iconData: Icons.restart_alt,
            iconSize: AppSettings.fontSizeH3,
          ),
        ),
      ],
    );
  }

  Widget buildGym(BuildContext context, Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Gym"),
        AppSettings.hasConnection
            ? FlexusButton(
                text: currentGym != null ? currentGym!.name : "Choose Gym",
                fontColor: currentGym != null ? AppSettings.font : AppSettings.primary,
                function: () async {
                  dynamic result = await showSearch(context: context, delegate: MyGymSearchDelegate());
                  if (result != null) {
                    setState(() {
                      currentGym = result;
                    });
                  }
                },
                width: deviceSize.width * 0.9,
              )
            : FlexusButton(
                text: "Internet connection required!",
                fontColor: AppSettings.error,
                function: () {},
                width: deviceSize.width * 0.9,
              ),
      ],
    );
  }

  Widget buildPlan(BuildContext context, Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Plan Name"),
        FlexusButton(
          text: currentPlan != null ? currentPlan!.plan.name : "Choose Plan",
          fontColor: currentPlan != null ? AppSettings.font : AppSettings.primary,
          function: () async {
            dynamic result = await showSearch(context: context, delegate: PlanSearchDelegate());
            if (result != null) {
              if (currentPlan != null) {
                currentPlan!.plan = result;
                currentPlan!.splits = [];
              } else {
                currentPlan = CurrentPlan(plan: result, currentSplit: 0, splits: []);
              }
              setState(() {});
            }
          },
          width: deviceSize.width * 0.9,
        ),
      ],
    );
  }

  Widget buildSplit(BuildContext context, Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlexusBasicTitle(deviceSize: deviceSize, text: "Today's Split"),
        FlexusButton(
          text: currentPlan != null
              ? currentPlan!.splits.isNotEmpty
                  ? currentPlan!.splits[currentPlan!.currentSplit].name
                  : "Choose Split"
              : "Choose Plan first",
          fontColor: currentPlan != null && currentPlan!.splits.isNotEmpty ? AppSettings.font : AppSettings.primary,
          function: currentPlan != null
              ? () async {
                  dynamic result = await showSearch(context: context, delegate: SplitSearchDelegate(plan: currentPlan!.plan));
                  if (result != null) {
                    setState(() {
                      currentPlan = result;
                    });
                  }
                }
              : () {},
          width: deviceSize.width * 0.9,
        ),
      ],
    );
  }

  Widget buildStart(BuildContext context, Size deviceSize) {
    return Center(
      child: FlexusButton(
        text: "Start",
        function: () {
          if (widget.workout != null) {
            workoutBloc.add(PatchWorkout(
              gymID: currentGym?.id,
              splitID: currentPlan != null
                  ? currentPlan!.splits.isNotEmpty
                      ? currentPlan!.splits[currentPlan!.currentSplit].id
                      : null
                  : null,
              workoutID: widget.workout!.id,
              name: "startWorkout",
            ));
          } else {
            workoutBloc.add(PostWorkout(
              gymID: currentGym?.id,
              splitID: currentPlan != null
                  ? currentPlan!.splits.isNotEmpty
                      ? currentPlan!.splits[currentPlan!.currentSplit].id
                      : null
                  : null,
              startTime: DateTime.now(),
              isActive: true,
            ));
          }
        },
        backgroundColor: AppSettings.primary,
        fontColor: AppSettings.fontV1,
      ),
    );
  }
}
