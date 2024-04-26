import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/gym/gym.dart';
import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
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
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class StartWorkoutPage extends StatefulWidget {
  const StartWorkoutPage({super.key});

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {
  final userBox = Hive.box('userBox');
  final WorkoutBloc workoutBloc = WorkoutBloc();

  Gym? currentGym;
  Plan? currentPlan;
  Split? currentSplit;

  @override
  void initState() {
    currentGym = userBox.get("currentGym");
    currentPlan = userBox.get("currentPlan");
    currentSplit = userBox.get("currentSplit");

    super.initState();
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
          if (state is WorkoutCreated) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: DocumentWorkoutPage(gym: currentGym, plan: currentPlan, split: currentSplit),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WorkoutCreating || state is WorkoutCreated) {
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
                    buildBottom(context, deviceSize),
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
              currentSplit = null;
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
        FlexusButton(
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
          text: currentPlan != null ? currentPlan!.name : "Choose Plan",
          fontColor: currentPlan != null ? AppSettings.font : AppSettings.primary,
          function: () async {
            dynamic result = await showSearch(context: context, delegate: PlanSearchDelegate());
            if (result != null) {
              currentSplit = null;
              setState(() {
                currentPlan = result;
              });
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
              ? currentSplit != null
                  ? currentSplit!.name
                  : "Choose Split"
              : "Choose Plan first",
          fontColor: currentSplit != null ? AppSettings.font : AppSettings.primary,
          function: currentPlan != null
              ? () async {
                  dynamic result = await showSearch(context: context, delegate: SplitSearchDelegate(planID: currentPlan!.id));
                  if (result != null) {
                    setState(() {
                      currentSplit = result;
                    });
                  }
                }
              : () {},
          width: deviceSize.width * 0.9,
        ),
      ],
    );
  }

  Widget buildBottom(BuildContext context, Size deviceSize) {
    return Center(
      child: FlexusButton(
        text: "Start",
        function: () {
          workoutBloc.add(PostWorkout(gymID: currentGym?.id, splitID: currentSplit?.id, startTime: DateTime.now()));
        },
        backgroundColor: AppSettings.primary,
        fontColor: AppSettings.fontV1,
      ),
    );
  }
}
