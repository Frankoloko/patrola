import 'package:flutter/material.dart';

Future<String> asyncListDialog({BuildContext context, List<dynamic> options}) async {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        content: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(options[index]),
              onTap: () {
                Navigator.pop(context, options[index]);
              },
            );
          },
        ),
      );
    }
  );
}
