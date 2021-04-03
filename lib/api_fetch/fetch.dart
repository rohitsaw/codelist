import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../model/contest.dart';
import 'credientials.dart';

Future<void> fetchContests(Box<Contest> contestBox, Box settingBox) async {
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  print("current date is $date");
  var url =
      'https://clist.by/api/v1/contest/?username=$username&api_key=$key&end__gte=$date&order_by=end';

  final response = await http.get(url);
  print("response ready");

  if (response.statusCode == 200) {
    await contestBox.clear();
    print("response is ok");

    var tmp = jsonDecode(response.body)['objects'];

    List<Contest> tmpList = [];
    for (int i = 0; i < tmp.length; i++) {
      tmpList.add(Contest.fromJSON(tmp[i]));
    }

    print("list ready ${tmpList.length}");

    await contestBox.addAll(tmpList);
    print("first contest date is ${contestBox.getAt(0).endDate.toString()}");
    print("new contest loaded");
  } else {
    throw Exception('Failed to load contests');
  }
}

Future<void> fetchIcons(Box settingBox) async {
  final url =
      "https://clist.by:443/api/v1/resource/?username=$username&api_key=$key";
  final response = await http.get(url);

  if (response.statusCode == 200) {
    await settingBox.clear();

    settingBox.put('isIST', true);
    var tmp = jsonDecode(response.body)['objects'];

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    List<String> allPlatform = [];
    List<String> selectedPlatform = [];

    tmp.forEach((val) {
      allPlatform.add(val['name']);
    });
    await settingBox.put("allPlatform", allPlatform);
    await settingBox.put("selectedPlatform", selectedPlatform);



    tmp.forEach((val) async {
      var logoUrl = "http://clist.by/${val['icon']}";
      var response = await http.get(logoUrl);
      File file = File(join(appDocPath, '${val['id']}'));
      file.writeAsBytesSync(response.bodyBytes);
      settingBox.put(val["id"], file.path);
    });

  } else {
    throw Exception('Failed to load icons');
  }
}
