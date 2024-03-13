import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FlexusWorkoutListTile extends StatelessWidget {
  final WorkoutOverview workoutOverview;
  final WorkoutBloc workoutBloc;
  final String? query;

  const FlexusWorkoutListTile({
    super.key,
    required this.workoutOverview,
    required this.workoutBloc,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final workout = workoutOverview.workout;

    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            backgroundColor: AppSettings.primary,
            icon: Icons.push_pin,
            label: workout.isPinned ? "Unpin" : "Pin",
            foregroundColor: AppSettings.fontV1,
            onPressed: workout.isPinned
                ? (context) async {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isPinned", value: false));
                    await Future.delayed(const Duration(milliseconds: 10));
                    workoutBloc.add(GetWorkout(isArchive: workout.isArchived));
                  }
                : (context) async {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isPinned", value: true));
                    await Future.delayed(const Duration(milliseconds: 10));
                    workoutBloc.add(GetWorkout(isArchive: workout.isArchived));
                  },
          ),
          SlidableAction(
            backgroundColor: Colors.amber,
            icon: Icons.star,
            label: workout.isStared ? "Unstar" : "Star",
            foregroundColor: AppSettings.fontV1,
            onPressed: workout.isStared
                ? (context) async {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isStared", value: false));
                    await Future.delayed(const Duration(milliseconds: 10));
                    workoutBloc.add(GetWorkout(isArchive: workout.isArchived));
                  }
                : (context) async {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isStared", value: true));
                    await Future.delayed(const Duration(milliseconds: 10));
                    workoutBloc.add(GetWorkout(isArchive: workout.isArchived));
                  },
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            backgroundColor: AppSettings.primary,
            icon: workout.isArchived ? Icons.unarchive : Icons.archive,
            label: workout.isArchived ? "Unarchive" : "Archive",
            foregroundColor: AppSettings.fontV1,
            onPressed: workout.isArchived
                ? (context) {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: true, name: "isArchived", value: false));
                  }
                : (context) {
                    workoutBloc.add(PatchWorkout(workoutID: workout.id, name: "isArchived", value: true));
                  },
          ),
          SlidableAction(
            backgroundColor: AppSettings.error,
            icon: Icons.delete,
            label: "Delete",
            foregroundColor: AppSettings.fontV1,
            onPressed: (context) {
              workoutBloc.add(DeleteWorkout(workoutID: workout.id));
            },
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
        tileColor: AppSettings.background,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: ViewWorkoutPage(
                workoutID: workout.id,
              ),
            ),
          );
        },
        leading: buildDate(workout),
        title: buildTitle(),
        subtitle: buildSubtitle(workout, userBox),
      ),
    );
  }

  Row buildSubtitle(Workout workout, Box<dynamic> userBox) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "${DateFormat('hh:mm').format(workout.starttime)} - ",
              style: TextStyle(
                fontSize: AppSettings.fontSizeDescription,
                color: AppSettings.font,
              ),
            ),
            workout.endtime != null
                ? Text(
                    "${DateFormat('hh:mm').format(workout.endtime!)} ",
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeDescription,
                      color: AppSettings.font,
                    ),
                  )
                : Text(
                    " still ongoing ...",
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeDescription,
                      color: AppSettings.font,
                    ),
                  ),
            workout.endtime != null
                ? Text(
                    "(${workout.endtime!.difference(workout.starttime).inMinutes} min)",
                    style: TextStyle(
                      fontSize: AppSettings.fontSizeDescription,
                      color: AppSettings.font,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        userBox.get("splits") != null
            ? Text(
                DateFormat('dd.MM.yyyy').format(workout.starttime),
                style: TextStyle(
                  fontSize: AppSettings.fontSizeDescription,
                  color: AppSettings.font,
                ),
              )
            : Text(
                DateFormat('dd.MM.yyyy').format(workout.starttime),
                style: TextStyle(
                  fontSize: AppSettings.fontSizeDescription,
                  color: AppSettings.font,
                ),
              ),
      ],
    );
  }

  Row buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        workoutOverview.splitName != null
            ? highlightTitle(workoutOverview.splitName!)
            : Text(
                "Custom Workout",
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: AppSettings.font,
                ),
              ),
        //Get actual PRs
        Row(
          children: [
            Visibility(
              visible: workoutOverview.workout.isPinned,
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: AppSettings.fontSize,
                    color: AppSettings.primary,
                  ),
                  SizedBox(width: AppSettings.screenWidth * 0.02),
                ],
              ),
            ),
            Visibility(
              visible: workoutOverview.workout.isStared,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: AppSettings.fontSize,
                    color: Colors.amber,
                  ),
                  SizedBox(width: AppSettings.screenWidth * 0.02),
                ],
              ),
            ),
            Visibility(
              visible: workoutOverview.workout.id % 7 != 0,
              child: Row(
                children: [
                  Text(
                    (workoutOverview.workout.id % 7).toString(),
                    style: TextStyle(fontSize: AppSettings.fontSize, color: AppSettings.font),
                  ),
                  Icon(
                    Icons.emoji_events,
                    size: AppSettings.fontSize,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget highlightTitle(String splitName) {
    if (query != null && query != "") {
      if (splitName.toLowerCase().contains(query!.toLowerCase())) {
        int startIndex = workoutOverview.splitName!.toLowerCase().indexOf(query!.toLowerCase());
        int endIndex = startIndex + query!.length;

        return RichText(
          text: TextSpan(
            text: startIndex > 0 ? splitName.substring(0, startIndex) : "",
            style: TextStyle(
              fontSize: AppSettings.fontSize,
              color: Colors.grey,
            ),
            children: [
              TextSpan(
                text: splitName.substring(startIndex, endIndex),
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: AppSettings.font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: endIndex < splitName.length ? splitName.substring(endIndex) : "",
                style: TextStyle(
                  fontSize: AppSettings.fontSize,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(
        text: splitName,
        style: TextStyle(
          fontSize: AppSettings.fontSize,
          color: AppSettings.font,
        ),
      ),
    );
  }

  CircleAvatar buildDate(Workout workout) {
    return CircleAvatar(
      radius: AppSettings.fontSizeTitle,
      backgroundColor: AppSettings.primaryShade48,
      child: Text(
        _getWeekdayAbbreviation(workout.starttime.weekday),
        style: TextStyle(
          fontSize: AppSettings.fontSizeTitleSmall,
          color: AppSettings.font,
        ),
      ),
    );
  }
}

String _getWeekdayAbbreviation(int index) {
  final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  return weekdays[index % 7];
}
