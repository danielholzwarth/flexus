import 'package:app/bloc/exercise_bloc/exercise_bloc.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/flexus_textfield.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:app/widgets/style/flexus_get_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  State<CreateExercisePage> createState() => _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  ExerciseBloc exerciseBloc = ExerciseBloc();

  final nameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final durationController = TextEditingController();

  bool isRepetition = true;

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: CustomDefaultTextStyle(
          text: 'Create new Exercise',
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
      ),
      body: BlocListener(
        bloc: exerciseBloc,
        listener: (context, state) {
          if (state is ExerciseCreated) {
            FlexusGet.showGetSnackbar(message: "Exercise created!");
          } else if (state is ExerciseError) {
            FlexusGet.showGetSnackbar(message: "Error creating exercise!");
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildName(deviceSize),
              buildType(deviceSize),
              // buildGoal(deviceSize),
              buildCreate(deviceSize),
              SizedBox(height: deviceSize.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildName(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: deviceSize.width * 0.05,
            top: deviceSize.height * 0.03,
            bottom: deviceSize.height * 0.01,
          ),
          child: CustomDefaultTextStyle(
            text: 'Exercise Name',
            fontWeight: FontWeight.bold,
            fontSize: AppSettings.fontSizeH3,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: FlexusTextField(
            hintText: "Name",
            textController: nameController,
            width: deviceSize.width * 0.9,
            onChanged: (String newValue) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget buildType(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: deviceSize.width * 0.05,
            top: deviceSize.height * 0.02,
            bottom: deviceSize.height * 0.01,
          ),
          child: CustomDefaultTextStyle(
            text: 'Type',
            fontWeight: FontWeight.bold,
            fontSize: AppSettings.fontSizeH3,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlexusButton(
              text: "Repetition",
              width: deviceSize.width * 0.4,
              fontColor: isRepetition ? AppSettings.primary : AppSettings.font,
              function: () {
                setState(() {
                  isRepetition = true;
                });
              },
            ),
            FlexusButton(
              text: "Duration",
              width: deviceSize.width * 0.4,
              fontColor: !isRepetition ? AppSettings.primary : AppSettings.font,
              function: () {
                setState(() {
                  isRepetition = false;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGoal(Size deviceSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: deviceSize.width * 0.05,
            top: deviceSize.height * 0.03,
            bottom: deviceSize.height * 0.01,
          ),
          child: CustomDefaultTextStyle(
            text: 'Goal',
            fontWeight: FontWeight.bold,
            fontSize: AppSettings.fontSizeH3,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceSize.width * 0.05),
          child: isRepetition
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlexusTextField(
                      hintText: "Sets",
                      textController: setsController,
                      width: deviceSize.width * 0.25,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Reps",
                      textController: repsController,
                      width: deviceSize.width * 0.25,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Weigth",
                      textController: weightController,
                      width: deviceSize.width * 0.25,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlexusTextField(
                      hintText: "Sets",
                      textController: setsController,
                      width: deviceSize.width * 0.4,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                    FlexusTextField(
                      hintText: "Duration",
                      textController: durationController,
                      width: deviceSize.width * 0.4,
                      onChanged: (String newValue) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget buildCreate(Size deviceSize) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: deviceSize.height * 0.15),
        child: FlexusButton(
          backgroundColor: AppSettings.primary,
          fontColor: AppSettings.fontV1,
          text: "Create",
          function: () {
            exerciseBloc.add(PostExercise(
              name: nameController.text,
              isRepetition: isRepetition,
            ));
          },
        ),
      ),
    );
  }
}
