import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StopWatch extends StatefulWidget {
  final int time;
  final String? subtitle;
  final String title;
  final bool autoStart;
  final Function(int) onAdd;
  final Function(int) getTimeSpent;
  const StopWatch({
    required this.time,
    required this.title,
    this.subtitle,
    this.autoStart = false,
    required this.onAdd,
    required this.getTimeSpent,
    Key? key,
  }) : super(key: key);

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  late StopWatchTimer stopWatchTimer;
  int time = 0;
  int totalAddedTIme = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    time = widget.time;
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(time),
    );

    if (widget.autoStart) {
      stopWatchTimer.onStartTimer();
    }

    void onTap() {
      if (stopWatchTimer.isRunning) {
        stopWatchTimer.onStopTimer();
      } else {
        stopWatchTimer.onStartTimer();
      }
    }

    void onAddTime(int addTime) {
      stopWatchTimer.onResetTimer();
      setState(() {
        time += addTime;
        totalAddedTIme += addTime;
      });
      widget.onAdd(addTime);
    }

    return // Timer goes here
        StreamBuilder(
      stream: stopWatchTimer.rawTime,
      initialData: 0,
      builder: (ctx, snapshot) {
        final value = snapshot.data;
        final displayTime = StopWatchTimer.getDisplayTime(value!);
        time = (value / 1000).round();
        widget.getTimeSpent(widget.time - time);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    color: Colors.white,
                  ),
            ),
            if (widget.subtitle != null) Text(widget.subtitle!),
            GestureDetector(
              onTap: onTap,
              child: CircularPercentIndicator(
                backgroundColor: Colors.black,
                progressColor: Colors.white,
                radius: 17.w,
                percent: 1 - (value / ((widget.time + totalAddedTIme) * 1000)),
                center: Text(
                    value == 0 ? 'Done' : displayTime.substring(3).toString()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onAddTime(5),
                  child: Text(
                    "+5",
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => onAddTime(10),
                  child: Text(
                    "+10",
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => onAddTime(15),
                  child: Text(
                    "+15",
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
