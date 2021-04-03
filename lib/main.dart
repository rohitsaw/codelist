import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import './model/contest.dart';
//import './widget/contest_card.dart';
import './api_fetch/fetch.dart';
import './appSettings.dart';
import 'widget/contest_card1.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MaterialApp(
      title: 'CodeList',
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      home: MyApp(),
    ),
  );
}
// clist.by

class MySplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('CodeList'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: Color(0xff435373),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  Future<Widget> loadApp() async {
    Hive.registerAdapter(ContestAdapter());
    await Hive.initFlutter();
    final contestBox = await Hive.openBox<Contest>('ContestBox');
    final settingBox = await Hive.openBox('settingBox');

    if (contestBox.length <= 0 || settingBox.length <= 0) {
      print("contest box length is ${contestBox.length}");
      print("settingBox length is ${settingBox.length}");

      await fetchIcons(settingBox);
      await fetchContests(contestBox, settingBox);
      return MyHomePage(
        title: 'Available Events',
        contestBox: contestBox,
        settingBox: settingBox,
      );
    } else {
      print("direct loading");
      return MyHomePage(
        title: 'Available Events',
        contestBox: contestBox,
        settingBox: settingBox,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadApp(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) return snapshot.data;
        return MySplashScreen();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.contestBox, this.settingBox})
      : super(key: key);

  final String title;
  final Box contestBox;
  final Box settingBox;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(widget, context),
      body: RefreshIndicator(
        onRefresh: () => fetchContests(widget.contestBox, widget.settingBox),
        child: ValueListenableBuilder(
          valueListenable:
              widget.settingBox.listenable(keys: ['selectedPlatform']),
          builder: (ctx, settingBox, _) => ValueListenableBuilder(
            valueListenable: widget.contestBox.listenable(),
            builder: (ctx, contestBox, _) {
              List<Contest> tmpList = [];

              DateTime endDate;
              DateTime today = DateTime.now();
              if (settingBox.get('selectedPlatform').length > 0) {
                for (int i = 0; i < contestBox.length; i++) {
                  endDate = contestBox.getAt(i).endDate;
                  if (settingBox
                          .get('selectedPlatform')
                          .contains(contestBox.getAt(i).title) &&
                      !endDate.isBefore(today)) {
                    tmpList.add(contestBox.getAt(i));
                  }
                }
              } else {
                for (int i = 0; i < contestBox.length; i++) {
                  endDate = contestBox.getAt(i).endDate;
                  if (!endDate.isBefore(today))
                    tmpList.add(contestBox.getAt(i));
                }
              }

              return Container(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ContestCard1(tmpList[index]);
                  },
                  itemCount: tmpList.length,
                  separatorBuilder: (ctx, index) => Divider(
                    thickness: 1,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final widget;
  final context;

  MyAppBar(this.widget, this.context);

  @override
  Size get preferredSize {
    return new Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: GoogleFonts.lato(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => AppSettings(widget.settingBox),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            showAboutDialog(
              context: context,
              applicationName: 'CodeList',
              applicationVersion: '1.0.1',
              applicationIcon: Image.asset(
                'asset/icon.png',
                width: 50,
                height: 50,
              ),
              children: [
                //Text("CodeList is an application, which is used to have a single place to view all the coding events happening across so many different platforms"),
                Text(
                    'This app aims is to promote and help competitive programming community.'),
                Divider(),
                Text(
                    'Select your favorite platform out of 70+ available platforms'),
                Divider(),
                Text(
                    'This app works in offline mode also, periodically refresh to load new data.'),
                Divider(),
                IconButton(
                  icon: Icon(Icons.mail_outline_sharp),
                  onPressed: () {
                    launch('https://rohitsaw.github.io');
                  },
                )
              ],
            );
          },
        ),
      ],
    );
  }
}
