import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout.dart';
import 'package:app/hive/workout_overview.dart';
import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
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

    return ListTile(
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
      trailing: buildTrailing(workout),
      subtitle: buildSubtitle(workout, userBox),
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

  PopupMenuButton<String> buildTrailing(Workout workout) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppSettings.font,
        size: AppSettings.fontSizeTitle,
      ),
      itemBuilder: (BuildContext context) {
        return workout.isArchived
            ? {'Unarchive', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList()
            : {'Archive', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
      },
      onSelected: (String choice) {
        switch (choice) {
          case "Archive":
            workoutBloc.add(PatchWorkout(workoutID: workout.id, name: "isArchived", value: true));
            break;
          case "Unarchive":
            workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: true, name: "isArchived", value: false));
            break;
          case "Delete":
            workoutBloc.add(DeleteWorkout(workoutID: workout.id));
            break;
          default:
            debugPrint("not implemented yed");
        }
      },
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
        Visibility(
          visible: workoutOverview.workout.id % 7 > 0,
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
    );
  }

  Widget highlightTitle(String splitName) {
    if (query != null && query != "") {
      if (splitName.toLowerCase().contains(query!.toLowerCase())) {
        int startIndex = workoutOverview.splitName!.toLowerCase().indexOf(query!.toLowerCase());
        int endIndex = startIndex + query!.length;

        return RichText(
          text: TextSpan(
            text: startIndex > 1 ? splitName.substring(0, startIndex) : "",
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
