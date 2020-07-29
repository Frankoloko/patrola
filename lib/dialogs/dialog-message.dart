import 'package:flutter/material.dart';

Future<bool> asyncMessageDialog({BuildContext context, String text, String title}) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title != null ? Text(title) : Text('Alert'),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}