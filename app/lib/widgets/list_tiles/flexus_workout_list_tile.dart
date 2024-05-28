import 'package:app/bloc/workout_bloc/workout_bloc.dart';
import 'package:app/hive/workout/workout.dart';
import 'package:app/hive/workout/workout_overview.dart';
import 'package:app/pages/plan/plan.dart';
import 'package:app/pages/workout/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_icon.dart';
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
  final Function()? onTap;
  final bool isPending;

  const FlexusWorkoutListTile({
    super.key,
    required this.workoutOverview,
    required this.workoutBloc,
    this.query,
    this.onTap,
    this.isPending = false,
  });

  @override
  State<FlexusWorkoutListTile> createState() => _FlexusWorkoutListTileState();
}

class _FlexusWorkoutListTileState extends State<FlexusWorkoutListTile> {
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    final userBox = Hive.box('userBox');
    final workout = widget.workoutOverview.workout;

    return Slidable(
      startActionPane: workout.endtime != null || !widget.isPending ? buildStartActionPane(workout) : null,
      endActionPane: !widget.isPending ? buildEndActionPane(workout) : null,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
        tileColor: widget.isPending
            ? Colors.amber.withOpacity(0.3)
            : workout.endtime == null
                ? workout.isActive
                    ? AppSettings.primaryShade48
                    : AppSettings.blocked.withOpacity(0.4)
                : AppSettings.background,
        onTap: !widget.isPending
            ? widget.onTap ??
                () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ViewWorkoutPage(
                          workoutID: workout.id,
                        ),
                      ),
                    )
            : () {},
        leading: buildDate(workout),
        title: buildTitle(deviceSize),
        subtitle: buildSubtitle(workout, userBox),
      ),
    );
  }

  ActionPane buildEndActionPane(Workout workout) {
    return workout.endtime != null
        ? ActionPane(
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
          )
        : ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.25,
            children: [
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
              text: "${DateFormat('HH:mm').format(workout.starttime)} ",
              fontSize: AppSettings.fontSizeT2,
            ),
            workout.endtime != null
                ? CustomDefaultTextStyle(
                    text: "- ${DateFormat('HH:mm').format(workout.endtime!)} ",
                    fontSize: AppSettings.fontSizeT2,
                  )
                : workout.isActive
                    ? CustomDefaultTextStyle(
                        text: "(in progress)",
                        fontSize: AppSettings.fontSizeT2,
                      )
                    : CustomDefaultTextStyle(
                        text: "(planned)",
                        fontSize: AppSettings.fontSizeT2,
                      ),
            workout.endtime != null
                ? CustomDefaultTextStyle(
                    text: getCorrectDurationString(workout.starttime, workout.endtime!),
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

  Row buildTitle(Size deviceSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.workoutOverview.splitName != null
            ? highlightTitle(widget.workoutOverview.splitName!)
            : !widget.isPending
                ? widget.workoutOverview.workout.endtime != null
                    ? const CustomDefaultTextStyle(text: "Custom Workout")
                    : const CustomDefaultTextStyle(text: "Start Workout")
                : const CustomDefaultTextStyle(text: "Pending"),
        Row(
          children: [
            Visibility(
              visible: widget.workoutOverview.workout.isPinned,
              child: Row(
                children: [
                  FlexusDefaultIcon(
                    iconData: Icons.push_pin,
                    iconSize: AppSettings.fontSize,
                    iconColor: AppSettings.primary,
                  ),
                  SizedBox(width: deviceSize.width * 0.02),
                ],
              ),
            ),
            Visibility(
              visible: widget.workoutOverview.workout.isStared,
              child: Row(
                children: [
                  FlexusDefaultIcon(
                    iconData: Icons.star,
                    iconSize: AppSettings.fontSize,
                    iconColor: Colors.amber,
                  ),
                  SizedBox(width: deviceSize.width * 0.02),
                ],
              ),
            ),
            Visibility(
              visible: !widget.isPending && widget.workoutOverview.bestLiftCount > 0,
              child: Row(
                children: [
                  CustomDefaultTextStyle(
                    text: widget.workoutOverview.bestLiftCount.toString(),
                  ),
                  FlexusDefaultIcon(
                    iconData: Icons.emoji_events,
                    iconSize: AppSettings.fontSize,
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

        return Row(
          children: [
            CustomDefaultTextStyle(
              text: startIndex > 0 ? splitName.substring(0, startIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
            CustomDefaultTextStyle(text: splitName.substring(startIndex, endIndex)),
            CustomDefaultTextStyle(
              text: endIndex < splitName.length ? splitName.substring(endIndex) : "",
              color: AppSettings.font.withOpacity(0.5),
            ),
          ],
        );
      }
    }
    return CustomDefaultTextStyle(
      text: splitName,
    );
  }

  CircleAvatar buildDate(Workout workout) {
    return CircleAvatar(
      radius: AppSettings.fontSizeH3,
      backgroundColor: AppSettings.primaryShade48,
      child: CustomDefaultTextStyle(
        text: getWeekday(workout.starttime.weekday, true),
        fontSize: AppSettings.fontSizeH4,
      ),
    );
  }
}

String getCorrectDurationString(DateTime first, DateTime? second) {
  if (second != null) {
    int minutes = second.difference(first).inMinutes.abs();
    if (minutes < 1) {
      return first.minute != second.minute ? "(1 min)" : "(0 min)";
    }

    return "($minutes min)";
  } else {
    return "-";
  }
}
