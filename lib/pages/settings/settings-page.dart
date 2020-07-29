import 'package:flutter/material.dart';

import 'package:Patrola/other/drawer-widget.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Text('Settings page'),
    );
  }
}
