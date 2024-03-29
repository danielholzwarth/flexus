import 'package:app/hive/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/flexus_simple_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({super.key});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  int currentStep = 0;

  final nameController = TextEditingController();
  final splitCountController = TextEditingController();

  int splitCount = 0;
  List<TextEditingController> splitControllers = [];

  //Get Exercises for each split
  Map<String, List<Exercise>> exerciseList = {};

  //Get Split Order
  List<String> defaultData = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  List<String> weeklyAcceptedData = ["", "", "", "", "", "", ""];
  int orderRestCount = 0;
  List<String> orderAcceptedData = [];

  bool isWeeklyRepetetive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Plan'),
        centerTitle: true,
      ),
      body: Stepper(
        steps: [
          Step(
            isActive: currentStep == 0,
            state: currentStep == 0
                ? StepState.editing
                : nameController.text.isNotEmpty
                    ? StepState.complete
                    : StepState.error,
            title: const Text("Name"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Give your workout plan a name so you can remember it better."),
                FlexusTextFormField(
                  hintText: "Name",
                  textController: nameController,
                  onChanged: (String newValue) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          Step(
            isActive: currentStep == 1,
            state: currentStep < 1
                ? StepState.indexed
                : currentStep == 1
                    ? StepState.editing
                    : splitCountController.text.isNotEmpty
                        ? StepState.complete
                        : StepState.error,
            title: const Text("Number of Splits"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("How many splits does your workout consist of?"),
                FlexusTextFormField(
                  hintText: "Count",
                  textController: splitCountController,
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (String newValue) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          Step(
            isActive: currentStep == 2,
            state: currentStep < 2
                ? StepState.indexed
                : currentStep == 2
                    ? StepState.editing
                    : splitControllers.any((element) => element.text.isEmpty) || splitControllers.isEmpty
                        ? StepState.error
                        : StepState.complete,
            title: const Text("Split Names"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Give your Splits a name. Choose names which describe your workout (e.g. Chest Bizeps)."),
                for (int index = 0; index < splitControllers.length; index++)
                  FlexusTextFormField(
                    hintText: "Split ${index + 1}",
                    textController: splitControllers[index],
                    onChanged: (String newValue) {
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          Step(
            isActive: currentStep == 3,
            state: currentStep < 3
                ? StepState.indexed
                : currentStep == 3
                    ? StepState.editing
                    : splitControllers.isEmpty
                        ? StepState.error
                        : StepState.complete,
            title: const Text("Exercises"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Choose from a list the default exercises for each split."),
                SizedBox(height: AppSettings.screenHeight * 0.02),
                for (int index = 0; index < splitControllers.length; index++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextButton(
                        onPressed: () async {
                          List<Exercise> splitExercises = await showSearch(context: context, delegate: ExerciseSearchDelegate());
                          exerciseList[splitControllers[index].text] = splitExercises;
                          setState(() {});
                        },
                        child: Text(
                          splitControllers[index].text,
                          style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font),
                        ),
                      ),
                      buildExercises(index),
                      SizedBox(height: AppSettings.screenHeight * 0.02),
                    ],
                  ),
              ],
            ),
          ),
          Step(
            isActive: currentStep == 4,
            state: currentStep < 4
                ? StepState.indexed
                : currentStep == 4
                    ? StepState.editing
                    : StepState.complete,
            title: const Text("Type"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Decide whether your plan should\nbe weekly repetetive or not."),
                    Switch(
                      value: isWeeklyRepetetive,
                      onChanged: (value) {
                        setState(() {
                          isWeeklyRepetetive = !isWeeklyRepetetive;
                        });
                      },
                      activeColor: AppSettings.primary,
                      activeTrackColor: AppSettings.primaryShade80,
                      inactiveThumbColor: AppSettings.primary,
                      inactiveTrackColor: AppSettings.background,
                      trackOutlineColor: MaterialStateProperty.resolveWith(
                        (final Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return null;
                          }

                          return AppSettings.primaryShade80;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSettings.screenHeight * 0.02),
                buildType(),
              ],
            ),
          ),
        ],
        onStepTapped: (value) {
          setState(() {
            currentStep = value;
          });
        },
        currentStep: currentStep,
        connectorColor: MaterialStatePropertyAll(AppSettings.primary),
        controlsBuilder: (context, details) {
          return Column(
            children: [
              SizedBox(height: AppSettings.screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (currentStep != 0) {
                        setState(() {
                          currentStep--;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'CANCEL',
                      style: TextStyle(color: AppSettings.font),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      switch (currentStep) {
                        case 1:
                          int newSplitCount = int.tryParse(splitCountController.text) ?? 0;
                          if (splitCount != newSplitCount) {
                            splitCount = newSplitCount;
                            splitControllers.clear();
                            for (int i = 0; i < splitCount; i++) {
                              splitControllers.add(TextEditingController());
                            }
                          }

                          break;
                      }

                      if (currentStep != 4) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        //Store in db
                        //Show created
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'CONTINUE',
                      style: TextStyle(color: AppSettings.primary),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildExercises(int index) {
    List<Exercise> exercises = exerciseList[splitControllers[index].text] ?? [];
    if (exercises.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < exercises.length; i++) Text("${i + 1}. ${exercises[i].name}"),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget buildType() {
    if (isWeeklyRepetetive) {
      return Column(
        children: [
          const Text("Drag your Split into the corresponding weekday."),
          SizedBox(height: AppSettings.screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int index = 0; index < splitControllers.length; index++)
                    if (splitControllers[index].text != "Rest")
                      Draggable(
                        data: splitControllers[index].text,
                        feedback: Material(
                          color: AppSettings.primaryShade48,
                          child: Container(
                            width: AppSettings.screenWidth * 0.3,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              splitControllers[index].text,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        child: Container(
                          width: AppSettings.screenWidth * 0.3,
                          color: AppSettings.primaryShade48,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            splitControllers[index].text,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  Draggable(
                    data: "Rest",
                    feedback: Material(
                      color: AppSettings.primaryShade48,
                      child: Container(
                        width: AppSettings.screenWidth * 0.3,
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          "Rest",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    child: Container(
                      width: AppSettings.screenWidth * 0.3,
                      color: AppSettings.primaryShade48,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const Text(
                        "Rest",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSettings.screenWidth * 0.1),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < 7; index++)
                    DragTarget(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: AppSettings.screenWidth * 0.3,
                          padding: const EdgeInsets.all(8),
                          color: weeklyAcceptedData[index].isNotEmpty ? AppSettings.confirm.withOpacity(0.5) : AppSettings.font.withOpacity(0.1),
                          margin: const EdgeInsets.only(bottom: 10),
                          alignment: Alignment.center,
                          child: Text(
                            weeklyAcceptedData[index].isNotEmpty ? weeklyAcceptedData[index] : defaultData[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                      onAcceptWithDetails: (value) {
                        setState(() {
                          if (value.data.toString() != "Rest") {
                            weeklyAcceptedData[index] = value.data.toString();
                          } else {
                            weeklyAcceptedData[index] = "";
                          }
                        });
                      },
                    ),
                ],
              )
            ],
          ),
        ],
      );
    } else {
      int itemCount = splitCount + orderRestCount;
      return Column(
        children: [
          const Text("Drag the Splits into the correct order."),
          SizedBox(height: AppSettings.screenHeight * 0.02),
          ReorderableListView(
            primary: false,
            shrinkWrap: true,
            children: List.generate(
              itemCount,
              (index) => ListTile(
                key: Key('$index'),
                title: Text("${index + 1}. ${splitControllers[index].text}"),
                trailing: const Icon(Icons.drag_handle),
              ),
            ),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex--;
                }
                final TextEditingController item = splitControllers.removeAt(oldIndex);
                splitControllers.insert(newIndex, item);
              });
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                orderRestCount++;
                splitControllers.add(TextEditingController(text: "Rest"));
              });
            },
            icon: const Icon(Icons.add),
          )
        ],
      );
    }
  }
}
