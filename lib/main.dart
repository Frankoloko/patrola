import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'advertisements/advertisement-bar.dart';

import 'package:Patrola/pages/login/login-page.dart';
import 'package:Patrola/pages/feedback/feedback-page.dart';
import 'package:Patrola/pages/groups/groups-page.dart';
import 'package:Patrola/pages/groups/groups-find-page.dart';
import 'package:Patrola/pages/patrols/patrols-page.dart';
import 'package:Patrola/pages/profile/profile-page.dart';
import 'package:Patrola/pages/settings/settings-page.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

import './global-values.dart' as globalValues;
import 'package:Patrola/dialogs/dialog-yesno.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MaterialAppContainer());
}

class MaterialAppContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MaterialAppContainerState();
  }
}

class _MaterialAppContainerState extends State<MaterialAppContainer> {
  reloadMainPageState() {
    setState(() {
      // This just reloads this component (no code needed here)
    });
  }

  @override
  void initState() {
    globalValues.reloadMainPageState = reloadMainPageState;
    super.initState();
  }

  // Routes and theme data
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'Patrola',
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.yellow,
          accentColor: Colors.yellow[600],
          cursorColor: Colors.yellow[300], // Change the caret color of inputs
          snackBarTheme:
              SnackBarThemeData(backgroundColor: Colors.yellow[600])),
      routes: <String, WidgetBuilder>{
        '/': (context) => LoginPage(),
        '/feedback': (context) => _buildPageBase(context, FeedbackPage()),
        '/groups': (context) => _buildPageBase(context, GroupsPage()),
        '/groups/find': (context) => _buildPageBase(context, GroupsFindPage()),
        '/patrols': (context) => _buildPageBase(context, PatrolsPage()),
        '/profile': (context) => _buildPageBase(context, ProfilePage()),
        '/settings': (context) => _buildPageBase(context, SettingsPage()),
      },
      // home: MaterialAppContainer()
    );
  }

  Widget _buildLoadingBar() {
    if (globalValues.showLoadingAnimation == false) return Container();

    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0),
      ),
    );
  }

  Widget _buildPatrolBar(BuildContext context) {
    if (globalValues.currentUser.currentPatrol == null) return Container();

    return Container(
      color: Colors.yellow[600],
      child: ListTile(
        title: Text(
          'YOU ARE ON PATROL',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.clear, color: Colors.black87),
        onTap: () {
          asyncYesNoDialog(
                  context: context,
                  title: 'End Patrol',
                  bodyText: 'Would you like to end your patrol?')
              .then((response) {
            if (!response) return;

            // Update the user's current patrol
            Firestore.instance
                .collection('users')
                .document(globalValues.currentUser.documentId)
                .updateData({'currentPatrol': null}).then((value) {
                  
              // Give the patrol an endDate of now
              Firestore.instance
                  .collection('patrols')
                  .document(globalValues.currentUser.currentPatrol)
                  .updateData({'endDate': DateTime.now()}).then((onValue) {
                globalValues.currentUser.currentPatrol = null;
                globalValues.reloadMainPageState();
              });
            });
          });
        },
      ),
    );
  }

  Widget _buildPageBase(BuildContext context, Widget pPage) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            AdvertisementBar(),
            _buildPatrolBar(context),
            Expanded(
              child: Stack(
                children: <Widget>[pPage, _buildLoadingBar()],
              ),
            )
          ],
        ),
      ),
    );
  }
}
