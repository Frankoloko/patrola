import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:Patrola/other/drawer-widget.dart';
import 'package:Patrola/dialogs/dialog-input.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../global-values.dart' as globalValues;

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  void _onSettingsSelected(String selectedItem) async {
    switch (selectedItem) {
      case 'Sign Out':
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('My Profile'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _onSettingsSelected,
            itemBuilder: (BuildContext context) {
              return ['Sign Out'].map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList();
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person, color: Colors.white54),
            title: Text('Display Name'),
            subtitle: Text(
              globalValues.currentUser.displayName,
              style: TextStyle(
                color: Theme.of(context).accentColor,
              ),
            ),
            trailing: Icon(Icons.edit, color: Colors.white30),
            onTap: () async {
              String returnText = await asyncInputDialog(
                  inputText: globalValues.currentUser.displayName,
                  title: 'Display Name',
                  context: context,
                  keyboardType: TextInputType.text);
              if (returnText != null) {
                setState(() {
                  print(globalValues.currentUser.documentId);
                  Firestore.instance
                      .collection('users')
                      .document(globalValues.currentUser.documentId)
                      .updateData({'displayName': returnText});
                  globalValues.currentUser.displayName = returnText;
                });
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.white54),
            title: Text('Phone Number'),
            subtitle: Text(globalValues.currentUser.phoneNumber,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                )),
            // trailing: Icon(Icons.edit, color: Colors.white30),
            // onTap: () async {
            //   String returnText = await asyncInputDialog(
            //       inputText: globalValues.currentUser.phoneNumber,
            //       title: 'Phone Number',
            //       context: context,
            //       keyboardType: TextInputType.phone,
            //       phoneNumberMask: true);
            //   if (returnText != null) {
            //     setState(() {
            //       globalValues.currentUser.phoneNumber = returnText;
            //       Firestore.instance.collection('users').document(globalValues.currentUser.documentId).updateData({'phoneNumber': returnText});
            //       globalValues.currentUser.phoneNumber = returnText;
            //     });
            //   }
            // },
          ),
        ],
      ),
    );
  }
}
