import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'contest.g.dart';

@HiveType(typeId: 0)
class Contest extends HiveObject {
  // contest id in clist.by

  @HiveField(0)
  int id;

  // contest duration in seconds
  @HiveField(1)
  int duration;

  // contest start date and time
  @HiveField(2)
  DateTime startDate;

  // contest end date and time
  @HiveField(3)
  DateTime endDate;

  // contest name
  @HiveField(4)
  String title;

  // contest link
  @HiveField(5)
  String link;

  // contest description
  @HiveField(6)
  String description;

  // contest logo
  @HiveField(7)
  int logoId;

  Contest({
    required this.id,
    required this.duration,
    required this.description,
    required this.title,
    required this.link,
    required this.logoId,
    required this.startDate,
    required this.endDate,
  });

  factory Contest.fromJSON(Map<dynamic, dynamic> json) {
    return Contest(
      id: json['id'],
      duration: json['duration'],
      startDate: DateFormat("yyyy-MM-dd HH:mm:ss")
          .parse(json['start'].replaceFirst("T", " "), true),
      endDate: DateFormat("yyyy-MM-dd HH:mm:ss")
          .parse(json['end'].replaceFirst("T", " "), true),
      description: json['event'],
      title: json['resource']['name'],
      link: json['href'],
      logoId: json['resource']['id'],
    );
  }
}
