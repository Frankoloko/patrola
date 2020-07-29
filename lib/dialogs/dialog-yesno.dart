import 'package:flutter/material.dart';

Future<bool> asyncYesNoDialog({BuildContext context, String title, String bodyText}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(bodyText),
        actions: <Widget>[
          FlatButton(
            child: Text('No', style: TextStyle(color: Colors.white54),),
            onPressed: () {
              Navigator.of(context).pop(false);
            }
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}