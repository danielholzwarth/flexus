import 'package:app/hive/plan/plan.dart';
import 'package:app/hive/split/split.dart';
import 'package:app/pages/workout/document_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/plan_search_delegate.dart';
import 'package:app/search_delegates/split_search_delegate.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/style/flexus_basic_title.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';

class StartWorkoutPage extends StatefulWidget {
  const StartWorkoutPage({super.key});

  @override
  State<StartWorkoutPage> createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<StartWorkoutPage> {
  final userBox = Hive.box('userBox');
  Plan? currentPlan;
  Split? currentSplit;

  @override
  void initState() {
    currentPlan = userBox.get("currentPlan");
    currentSplit = userBox.get("currentSplit");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppSettings.background,
      appBar: AppBar(
        title: CustomDefaultTextStyle(
          text: "Start Workout",
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
        backgroundColor: AppSettings.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPlan(context, deviceSize),
              buildSplit(context, deviceSize),
              SizedBox(height: deviceSize.height * 0.35),
              buildBottom(context, deviceSize),
            ],
          ),
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: deviceSize.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlexusButton(
                text: "Start",
                function: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: DocumentWorkoutPage(plan: currentPlan, split: currentSplit),
                    ),
                  );
                },
                backgroundColor: AppSettings.primary,
                fontColor: AppSettings.fontV1,
              ),
              SizedBox(height: deviceSize.height * 0.02),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppSettings.background),
                    surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
                    overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
                    foregroundColor: MaterialStateProperty.all(AppSettings.primary),
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.5))),
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: DocumentWorkoutPage(),
                    ),
                  );
                },
                child: const CustomDefaultTextStyle(text: "Start custom workout"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
