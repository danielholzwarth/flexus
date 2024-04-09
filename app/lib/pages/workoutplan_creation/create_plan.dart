import 'package:app/bloc/plan_bloc/plan_bloc.dart';
import 'package:app/hive/exercise/exercise.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/search_delegates/exercise_search_delegate.dart';
import 'package:app/widgets/flexus_simple_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({super.key});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  final PlanBloc planBloc = PlanBloc();
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

  bool isWeeklyRepetetive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Plan'),
        centerTitle: true,
      ),
      body: BlocConsumer(
        bloc: planBloc,
        listener: (context, state) {
          if (state is PlanCreated) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is PlanCreating) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: Center(child: CircularProgressIndicator(color: AppSettings.primary)),
            );
          } else if (state is PlanError) {
            return Scaffold(
              backgroundColor: AppSettings.background,
              body: Text(state.error),
            );
          } else {
            return Stepper(
              steps: [
                buildNameStep(),
                buildSplitNumberStep(),
                buildSplitNamesStep(),
                buildExercisesStep(context),
                buildTypeStep(),
              ],
              onStepTapped: (value) {
                setState(() {
                  currentStep = value;
                });
              },
              currentStep: currentStep,
              connectorColor: MaterialStatePropertyAll(AppSettings.primary),
              controlsBuilder: (context, details) {
                return buildControls(context);
              },
            );
          }
        },
      ),
    );
  }

  Column buildControls(BuildContext context) {
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
                  case 0:
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Plan Name can not be empty!"),
                          ),
                        ),
                      );
                    }
                    break;

                  case 1:
                    int newSplitCount = int.tryParse(splitCountController.text) ?? 0;
                    if (newSplitCount > 0) {
                      if (splitCount != newSplitCount) {
                        splitCount = newSplitCount;

                        splitControllers.clear();
                        for (int i = 0; i < splitCount; i++) {
                          splitControllers.add(TextEditingController());
                        }

                        exerciseList = {};

                        defaultData = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
                        weeklyAcceptedData = ["", "", "", "", "", "", ""];
                        orderRestCount = 0;
                        orderAcceptedData = [];

                        isWeeklyRepetetive = false;
                      }

                      setState(() {
                        currentStep++;
                      });
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Split Count must be greater than 0."),
                          ),
                        ),
                      );
                    }

                    break;

                  case 2:
                    if (splitControllers.any((element) => element.text.isEmpty)) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text("Each Split must have a Name."),
                          ),
                        ),
                      );
                    } else {
                      Set<String> uniqueTexts = {};
                      bool hasDuplicates = false;
                      for (var controller in splitControllers) {
                        if (!uniqueTexts.add(controller.text)) {
                          hasDuplicates = true;
                          break;
                        }
                      }

                      if (hasDuplicates) {
                        // Handle duplicate case
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                              child: Text("Duplicate texts are not allowed."),
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          currentStep++;
                        });
                      }
                    }

                  case 3:
                    setState(() {
                      currentStep++;
                    });

                  case 4:
                    List<bool> boolList = [];
                    List<String> splitNames = [];
                    List<List<int>> exerciseIDs = [];

                    if (isWeeklyRepetetive) {
                      for (int i = 0; i < weeklyAcceptedData.length; i++) {
                        boolList.add(weeklyAcceptedData[i].isEmpty);
                      }

                      for (int i = 0; i < weeklyAcceptedData.length; i++) {
                        if (weeklyAcceptedData[i].isEmpty) {
                          splitNames.add("Rest");
                          exerciseIDs.add([-1]);
                        } else {
                          splitNames.add(weeklyAcceptedData[i]);
                          List<Exercise> splitExercises =
                              exerciseList[splitControllers.firstWhere((element) => element.text == weeklyAcceptedData[i]).text] ?? [];
                          List<int> splitExerciseIDs = [];

                          for (int j = 0; j < splitExercises.length; j++) {
                            splitExerciseIDs.add(splitExercises[j].id);
                          }

                          exerciseIDs.add(splitExerciseIDs);
                        }
                      }
                    } else {
                      for (int i = 0; i < splitControllers.length; i++) {
                        splitNames.add(splitControllers[i].text);
                        if (exerciseList[splitControllers[i].text] != null) {
                          List<Exercise> splitExercises = exerciseList[splitControllers[i].text]!;
                          List<int> splitExerciseIDs = [];

                          for (int j = 0; j < splitExercises.length; j++) {
                            splitExerciseIDs.add(splitExercises[j].id);
                          }

                          exerciseIDs.add(splitExerciseIDs);
                        } else {
                          exerciseIDs.add([-1]);
                        }
                      }
                    }

                    planBloc.add(PostPlan(
                      splitCount: splitCount,
                      planName: nameController.text,
                      isWeekly: isWeeklyRepetetive,
                      weeklyRestList: boolList,
                      splits: splitNames,
                      exercises: exerciseIDs,
                    ));

                    break;

                  default:
                    break;
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
  }

  Step buildTypeStep() {
    return Step(
      isActive: currentStep == 4,
      state: currentStep < 4
          ? StepState.disabled
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
                    isWeeklyRepetetive = value;
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
    );
  }

  Step buildExercisesStep(BuildContext context) {
    return Step(
      isActive: currentStep == 3,
      state: currentStep < 3
          ? StepState.disabled
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  splitControllers[index].text,
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeTitleSmall,
                    color: AppSettings.font,
                  ),
                ),
                buildExercises(index),
                IconButton(
                  onPressed: () async {
                    List<Exercise> splitExercises = await showSearch(context: context, delegate: ExerciseCustomSearchDelegate());
                    exerciseList[splitControllers[index].text] = splitExercises;
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.add,
                    color: AppSettings.primary,
                    size: AppSettings.fontSize,
                  ),
                ),
                SizedBox(height: AppSettings.screenHeight * 0.04),
              ],
            ),
        ],
      ),
    );
  }

  Step buildSplitNamesStep() {
    return Step(
      isActive: currentStep == 2,
      state: currentStep < 2
          ? StepState.disabled
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
    );
  }

  Step buildSplitNumberStep() {
    return Step(
      isActive: currentStep == 1,
      state: currentStep < 1
          ? StepState.disabled
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
    );
  }

  Step buildNameStep() {
    return Step(
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
    );
  }

  Widget buildExercises(int index) {
    List<Exercise> exercises = exerciseList[splitControllers[index].text] ?? [];
    if (exercises.isNotEmpty) {
      return ReorderableListView(
        primary: false,
        shrinkWrap: true,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Exercise item = exercises.removeAt(oldIndex);
            exercises.insert(newIndex, item);
          });
        },
        children: List.generate(
          exercises.length,
          (index) {
            return ListTile(
              key: Key('$index'),
              title: Text(
                "${index + 1}. ${exercises[index].name}",
                style: TextStyle(fontSize: AppSettings.fontSize),
              ),
              trailing: Icon(
                Icons.drag_handle,
                size: AppSettings.fontSizeTitle,
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildType() {
    if (isWeeklyRepetetive) {
      return Column(
        children: [
          const Text("Drag your Split into the corresponding weekday. The default-value is a Rest-Day."),
          SizedBox(height: AppSettings.screenHeight * 0.04),
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
                        setState(
                          () {
                            if (value.data.toString() != "Rest") {
                              weeklyAcceptedData[index] = value.data.toString();
                            } else {
                              weeklyAcceptedData[index] = "";
                            }
                          },
                        );
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
          const Text("Drag the Splits into the correct order. If you need Rest-Days press on the plus icon below."),
          SizedBox(height: AppSettings.screenHeight * 0.04),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    orderRestCount = 0;
                    splitControllers.removeWhere((element) => element.text == "Rest");
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              SizedBox(width: AppSettings.screenWidth * 0.1),
              IconButton(
                onPressed: () {
                  setState(() {
                    orderRestCount++;
                    splitControllers.add(TextEditingController(text: "Rest"));
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          )
        ],
      );
    }
  }
}
