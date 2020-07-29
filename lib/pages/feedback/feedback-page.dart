import 'package:flutter/material.dart';

import 'package:Patrola/other/drawer-widget.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Text('Feedback page'),
    );
  }
}
