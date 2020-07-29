import 'package:flutter/material.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

import 'package:flutter_duration_picker/flutter_duration_picker.dart';
// https://pub.dev/packages/flutter_duration_picker

Future<bool> asyncNewPatrolDialog(BuildContext context) async {
  // rDuration _duration = Duration(hours: 0, minutes: 0);

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create New Patrol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DateTimePickerFormField(
              inputType: InputType.time,
              format: DateFormat("HH:mm"),
              editable: false,
              decoration: InputDecoration(
                  labelText: 'Duration',
                  hasFloatingPlaceholder: true
              ),
              onChanged: (value) {
                print(value);
              },
            ),
            // DurationPicker(
            //   duration: _duration,
            //   onChange: (val) {
            //     print(val);
            //   },
            //   snapToMins: 5.0,
            // )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white54),),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text('Create'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}