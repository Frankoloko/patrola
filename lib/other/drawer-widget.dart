import 'package:Patrola/dialogs/dialog-input.dart';
import 'package:Patrola/dialogs/dialog-message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../global-values.dart' as globalValues;

import 'list-seperator-widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Image.asset(
                'assets/app-icon.png',
                height: 100.0,
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_car, color: Colors.white30),
              title: Text('Patrols'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/patrols');
              },
            ),
            // ListSeparatorWidget(),
            ListTile(
              leading: Icon(Icons.group, color: Colors.white30),
              title: Text('My Groups'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/groups');
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white30),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ), 
            ListTile(
              leading: Icon(Icons.call, color: Colors.white30),
              title: Text('Contact Us'),
              onTap: () {
                globalValues.contactUs(context);
              },
            ), 
            // Divider(
            //   height: 15.0,
            //   color: Colors.black,
            // ),
            // ListTile(
            //   leading: Icon(Icons.settings),
            //   title: Text('Settings'),
            //   onTap: () {
            //     Navigator.pushReplacementNamed(context, '/settings');
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.insert_comment),
            //   title: Text('Feedback'),
            //   onTap: () {
            //     Navigator.pushReplacementNamed(context, '/feedback');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
