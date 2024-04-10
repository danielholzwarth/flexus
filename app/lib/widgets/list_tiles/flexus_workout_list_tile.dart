import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FlexusWorkoutListTile extends StatefulWidget {
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
  State<FlexusWorkoutListTile> createState() => _FlexusWorkoutListTileState();
}

class _FlexusWorkoutListTileState extends State<FlexusWorkoutListTile> {
  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final workout = widget.workoutOverview.workout;

    return Slidable(
      startActionPane: buildStartActionPane(workout),
      endActionPane: buildEndActionPane(workout),
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

  ActionPane buildEndActionPane(Workout workout) {
    return ActionPane(
      motion: const StretchMotion(),
      extentRatio: 0.5,
      children: [
        SlidableAction(
          backgroundColor: AppSettings.primary,
          icon: workout.isArchived ? Icons.unarchive : Icons.archive,
          label: workout.isArchived ? "Unarchive" : "Archive",
          foregroundColor: AppSettings.fontV1,
          onPressed: (context) => widget.workoutBloc
              .add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isArchived", value: !workout.isArchived)),
        ),
        SlidableAction(
          backgroundColor: AppSettings.error,
          icon: Icons.delete,
          label: "Delete",
          foregroundColor: AppSettings.fontV1,
          onPressed: (context) {
            widget.workoutBloc.add(DeleteWorkout(workoutID: workout.id, isArchive: workout.isArchived));
          },
        ),
      ],
    );
  }

  ActionPane buildStartActionPane(Workout workout) {
    return ActionPane(
      motion: const StretchMotion(),
      extentRatio: 0.5,
      children: [
        SlidableAction(
          backgroundColor: AppSettings.primary,
          icon: Icons.push_pin,
          label: workout.isPinned ? "Unpin" : "Pin",
          foregroundColor: AppSettings.fontV1,
          onPressed: (context) =>
              widget.workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isPinned", value: !workout.isPinned)),
        ),
        SlidableAction(
          backgroundColor: Colors.amber,
          icon: Icons.star,
          label: workout.isStared ? "Unstar" : "Star",
          foregroundColor: AppSettings.fontV1,
          onPressed: (context) =>
              widget.workoutBloc.add(PatchWorkout(workoutID: workout.id, isArchive: workout.isArchived, name: "isStared", value: !workout.isStared)),
        ),
      ],
    );
  }

  Row buildSubtitle(Workout workout, Box<dynamic> userBox) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomDefaultTextStyle(
              text: "${DateFormat('hh:mm').format(workout.starttime)} - ",
              fontSize: AppSettings.fontSizeT2,
            ),
            workout.endtime != null
                ? CustomDefaultTextStyle(
                    text: "${DateFormat('hh:mm').format(workout.endtime!)} ",
                    fontSize: AppSettings.fontSizeT2,
                  )
                : CustomDefaultTextStyle(
                    text: " still ongoing ...",
                    fontSize: AppSettings.fontSizeT2,
                  ),
            workout.endtime != null
                ? CustomDefaultTextStyle(
                    text: "(${workout.endtime!.difference(workout.starttime).inMinutes} min)",
                    fontSize: AppSettings.fontSizeT2,
                  )
                : const SizedBox(),
          ],
        ),
        userBox.get("splits") != null
            ? CustomDefaultTextStyle(
                text: DateFormat('dd.MM.yyyy').format(workout.starttime),
                fontSize: AppSettings.fontSizeT2,
              )
            : CustomDefaultTextStyle(
                text: DateFormat('dd.MM.yyyy').format(workout.starttime),
                fontSize: AppSettings.fontSizeT2,
              ),
      ],
    );
  }

  Row buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.workoutOverview.splitName != null
            ? highlightTitle(widget.workoutOverview.splitName!)
            : const CustomDefaultTextStyle(
                text: "Custom Workout",
              ),
        //Get actual PRs
        Row(
          children: [
            Visibility(
              visible: widget.workoutOverview.workout.isPinned,
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
              visible: widget.workoutOverview.workout.isStared,
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
              visible: widget.workoutOverview.workout.id % 7 != 0,
              child: Row(
                children: [
                  CustomDefaultTextStyle(
                    text: (widget.workoutOverview.workout.id % 7).toString(),
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
    if (widget.query != null && widget.query != "") {
      if (splitName.toLowerCase().contains(widget.query!.toLowerCase())) {
        int startIndex = widget.workoutOverview.splitName!.toLowerCase().indexOf(widget.query!.toLowerCase());
        int endIndex = startIndex + widget.query!.length;

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
      radius: AppSettings.fontSizeH3,
      backgroundColor: AppSettings.primaryShade48,
      child: CustomDefaultTextStyle(
        text: _getWeekdayAbbreviation(workout.starttime.weekday),
        fontSize: AppSettings.fontSizeH4,
      ),
    );
  }
}

String _getWeekdayAbbreviation(int index) {
  final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  return weekdays[index % 7];
}
