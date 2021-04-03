import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AppSettings extends StatefulWidget {
  final Box settingBox;
  AppSettings(this.settingBox);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 800,
      child: AlertDialog(
        title: Text('App Settings'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Local Time Zone "),
                  Switch(
                    value: widget.settingBox.get('isIST'),
                    onChanged: (val) {
                      setState(() {
                        widget.settingBox.put('isIST', val);
                      });
                    },
                  ),
                ],
              ),
              MultiSelectDialogField(
                items: [
                  ..._getFilterOptions(widget.settingBox.get('allPlatform'))
                ],
                listType: MultiSelectListType.CHIP,
                buttonText: Text('Show only selected'),
                searchable: true,
                onConfirm: (values) {
                  widget.settingBox.put('selectedPlatform', values);
                },
                initialValue: widget.settingBox.get('selectedPlatform'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

Iterable<MultiSelectItem> _getFilterOptions(List<String> allPlatform) sync* {
  //int len = filterName.length;
  for (String name in allPlatform) {
    yield MultiSelectItem(
      // value
      name,
      //label
      name,
    );
  }
}
