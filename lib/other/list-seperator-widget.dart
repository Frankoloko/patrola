import 'package:flutter/material.dart';

class ListSeparatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Divider(
        height: 1.0,
        color: Colors.grey,
      ),
    );
  }
}
