import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/contest.dart';

/// not in used
/// replace with contestcard1

class ContestCard extends StatelessWidget {
  final Contest contest;
  ContestCard(this.contest);

  @override
  Widget build(BuildContext context) {
    // storing tap position
    late Offset gpos;

    final Box settingBox = Hive.box('settingBox');

    return LayoutBuilder(
      builder: (ctx, device) => GestureDetector(
        onTapDown: (details) {
          gpos = details.globalPosition;
        },
        child: InkWell(
          onTap: () {},
          onLongPress: () {
            _showOptions(context, gpos, contest);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: device.maxWidth * 0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          contest.title.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          contest.description,
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      // start and ending date box
                      ValueListenableBuilder(
                        valueListenable: settingBox.listenable(keys: ["isIST"]),
                        builder: (ctx, Box box, widget) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 2.5, bottom: 2.5),
                              child: Text(
                                "Start at - ${DateFormat('dd MMM yyyy, h:mm a').format(box.get("isIST") ? contest.startDate.toLocal() : contest.startDate.toUtc())}",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 2.5, bottom: 2.5),
                              child: Text(
                                "End at - ${DateFormat('dd MMM yyyy, h:mm a').format(box.get("isIST") ? contest.endDate.toLocal() : contest.endDate.toUtc())}",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5),
                        child: Text(
                          "Duration - ${_getDuration(contest.duration)}",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: device.maxWidth * 0.24,
                  child: CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: (settingBox.get(contest.logoId) != null)
                          ? Image.file(
                              File(settingBox.get(contest.logoId)),
                              fit: BoxFit.contain,
                              width: 65,
                            )
                          : Icon(
                              Icons.hourglass_empty_rounded,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> _showOptions(context, gpos, contest) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  return showMenu(
    elevation: 2,
    context: context,
    position:
        RelativeRect.fromRect(gpos & Size(40, 40), Offset.zero & overlay.size),
    items: [
      PopupMenuItem(
        value: 0,
        child: GestureDetector(
          onTapUp: (details) => launchUrlString(contest.link),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.exit_to_app),
              SizedBox(
                width: 5,
              ),
              Text('Go to Official Website'),
            ],
          ),
        ),
      ),
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
          onTapUp: (details) {
            final Event event = Event(
              title: " ${contest.title} - ${contest.description}",
              description: contest.description,
              location: contest.title,
              startDate: contest.startDate.toLocal(),
              endDate: contest.endDate.toLocal(),
            );
            Add2Calendar.addEvent2Cal(event);
            print("event added to calender");
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.alarm),
              SizedBox(
                width: 5,
              ),
              Text('Set Reminder'),
            ],
          ),
        ),
      ),
    ],
  );
}

String _getDuration(int seconds) {
  int hours = ((seconds ~/ 60) ~/ 60);
  int minutes = ((seconds ~/ 60) % 60);

  if (hours <= 24 && minutes == 0) return "$hours hours";

  if (hours <= 24) return "$hours hours $minutes minutes";

  int days = hours ~/ 24;
  hours = hours % 24;

  if (hours == 0) {
    return "$days days";
  }

  return "$days days, $hours hours";
}
