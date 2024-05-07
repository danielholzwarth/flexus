import 'dart:async';

import 'package:app/hive/timer/timer_value.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/buttons/flexus_button.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({
    super.key,
    this.timerValue,
  });
  final TimerValue? timerValue;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Duration timerDuration = Duration.zero;
  Timer? timer;
  bool isRunning = false;
  List<Duration> rounds = [];

  @override
  void initState() {
    if (widget.timerValue != null && widget.timerValue!.isRunning && widget.timerValue!.milliseconds > 0) {
      timerDuration = Duration(milliseconds: widget.timerValue!.milliseconds);
      timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          timerDuration = timerDuration += const Duration(milliseconds: 10);
        });
      });
      isRunning = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, TimerValue(isRunning: timer?.isActive ?? false, milliseconds: timerDuration.inMilliseconds));
          },
        ),
        title: CustomDefaultTextStyle(
          text: 'Timer',
          fontSize: AppSettings.fontSizeH3,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTime(),
            buildRoundTimes(deviceSize),
            SizedBox(height: deviceSize.height * 0.03),
            buildStartButton(),
            SizedBox(height: deviceSize.height * 0.02),
            buildRoundButton(),
            SizedBox(height: deviceSize.height * 0.01),
            buildExit(context, deviceSize),
          ],
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String minutesString = duration.inMinutes >= 1 ? "${duration.inMinutes.toString().padLeft(1, '0')}:" : "";
    String secondsString = (duration.inSeconds % 60).toString().padLeft(2, '0');
    String millisecondsString = ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');

    return "$minutesString$secondsString:$millisecondsString";
  }

  Color getColorByDuration(int index, List<Duration> durations) {
    List<int> durationInts = rounds.map((duration) => duration.inMilliseconds).toList();

    int maxDuration = durationInts.reduce((value, element) => value > element ? value : element);
    int minDuration = durationInts.reduce((value, element) => value < element ? value : element);

    if (durationInts[index] == maxDuration) {
      return AppSettings.error;
    } else if (durationInts[index] == minDuration) {
      return AppSettings.confirm;
    } else {
      return AppSettings.font;
    }
  }

  Widget buildTime() {
    return Column(
      children: [
        CustomDefaultTextStyle(
          text: formatTime(timerDuration),
          fontSize: AppSettings.fontSizeBig,
        ),
      ],
    );
  }

  Widget buildRoundTimes(Size deviceSize) {
    return SizedBox(
      width: deviceSize.width,
      height: deviceSize.height * 0.25,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = rounds.length - 1; i >= 0; i--)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: deviceSize.height * 0.005),
                    child: CustomDefaultTextStyle(
                      text: "Round ${i + 1}: ${formatTime(rounds[i])}",
                      color: getColorByDuration(i, rounds),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStartButton() {
    return FlexusButton(
      text: isRunning
          ? "PAUSE"
          : timerDuration.inMilliseconds > 0
              ? "CONTINUE"
              : "START",
      function: () {
        if (!isRunning) {
          timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
            setState(() {
              timerDuration = timerDuration += const Duration(milliseconds: 10);
            });
          });
          setState(() {
            isRunning = true;
          });
        } else {
          setState(() {
            timer?.cancel();
            isRunning = false;
          });
        }
      },
      fontColor: AppSettings.fontV1,
      backgroundColor: AppSettings.primary,
    );
  }

  Widget buildRoundButton() {
    return FlexusButton(
      text: timerDuration.inMilliseconds > 0 && !isRunning ? "RESET" : "ROUND",
      function: () {
        if (timerDuration.inMilliseconds > 0 && !isRunning) {
          setState(() {
            rounds.clear();
            timerDuration = Duration.zero;
          });
        } else if (isRunning) {
          Duration currentRound = Duration.zero;
          if (rounds.isEmpty) {
            currentRound = timerDuration;
          } else {
            Duration allRoundDuration = Duration.zero;
            for (var round in rounds) {
              allRoundDuration = allRoundDuration + round;
            }
            currentRound = timerDuration - allRoundDuration;
          }

          setState(() {
            rounds.add(currentRound);
          });
        }
      },
      fontColor: timerDuration.inMilliseconds > 0 ? AppSettings.fontV1 : AppSettings.font,
      backgroundColor: timerDuration.inMilliseconds > 0 && isRunning
          ? AppSettings.primary
          : timerDuration.inMilliseconds > 0
              ? AppSettings.error
              : AppSettings.blocked,
    );
  }

  Widget buildExit(BuildContext context, Size deviceSize) {
    return TextButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor: MaterialStateProperty.all(AppSettings.background),
          overlayColor: MaterialStateProperty.all(AppSettings.primaryShade48),
          foregroundColor: MaterialStateProperty.all(AppSettings.primary),
          fixedSize: MaterialStateProperty.all(Size.fromWidth(deviceSize.width * 0.5))),
      onPressed: () async {
        Navigator.pop(context, TimerValue(isRunning: false, milliseconds: timerDuration.inMilliseconds));
      },
      child: CustomDefaultTextStyle(
        text: "Exit",
        fontSize: AppSettings.fontSizeH4,
      ),
    );
  }
}
