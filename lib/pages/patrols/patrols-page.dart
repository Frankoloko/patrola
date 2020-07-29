import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Patrola/other/drawer-widget.dart';
import 'package:Patrola/pages/patrols/new-patrol-dialog.dart';
import 'package:Patrola/dialogs/dialog-list.dart';
import 'package:Patrola/dialogs/dialog-input.dart';
import 'package:Patrola/dialogs/dialog-message.dart';
import 'package:Patrola/dialogs/dialog-yesno.dart';

import 'package:intl/intl.dart';

import '../../global-values.dart' as globalValues;

class PatrolsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PatrolsPageState();
  }
}

class _PatrolsPageState extends State<PatrolsPage> {
  Stream patrols;
  Stream notes;
  List<dynamic> groups = [''];
  String selectedGroup;

  @override
  void initState() {
    // Widget cannot do setState() as it is already setting the state by the build function
    // globalValues.showLoadingAnimation = false;
    // globalValues.reloadMainPageState();

    _changeGroup(groups[0]);
    // _setDisplayName();
    globalValues.reloadUserDetails(context).then((_) {
      setState(() {
        groups = globalValues.currentUser.groups;
        _changeGroup(groups[0]);
        globalValues.showLoadingAnimation = false;
        globalValues.reloadMainPageState();
      });
    });
    super.initState();
  }

  void _changeGroup(String newValue) {
    setState(() {
      this.selectedGroup = newValue;

      this.notes = Firestore.instance
          .collection('notes')
          .where('groups_name', isEqualTo: this.selectedGroup)
          .orderBy('createDate', descending: true)
          .snapshots();

      this.patrols = Firestore.instance
          .collection('patrols')
          .where('groups_name', isEqualTo: this.selectedGroup)
          .orderBy('endDate', descending: false)
          .snapshots();
    });
  }

  void _onSettingsSelected(String selectedItem) {
    switch (selectedItem) {
      case 'Switch Group':
        asyncListDialog(context: context, options: groups).then((value) {
          if (value != null) _changeGroup(value);
        });
        break;
    }
  }

  void _onFloatingButtonTapped(int tabIndex) {
    switch (tabIndex) {
      case 0: // Messages
        asyncInputDialog(
                context: context,
                keyboardType: TextInputType.text,
                title: 'New Note',
                doneText: 'Done')
            .then((response) {
          if (response == '' || response == null) return;

          // Post the new message to the database
          Firestore.instance.collection('notes').add({
            'message': response,
            'createDate': DateTime.now(),
            'groups_name': this.selectedGroup,
            'users_id': globalValues.currentUser.documentId,
            'users_displayName': globalValues.currentUser.displayName
          }).catchError((error) {
            print(error);
          }).then((document) {
            print(document);
          });
        });
        break;

      case 1: // Patrols
        if (globalValues.currentUser.currentPatrol != null) {
          asyncMessageDialog(context: context, text:
              'You need to end your current patrol to start a new one');
          return;
        }

        // asyncNewPatrolDialog(context).then((response) {
        asyncYesNoDialog(context: context, title: 'Start New Patrol', bodyText: 'Would you like to start your patrol now?').then((response) {
          if (!response) return;

          // Post new patrol to the database
          Firestore.instance.collection('patrols').add({
            'createDate': DateTime.now(),
            'endDate': null,
            'groups_name': this.selectedGroup,
            'users': [
              {
                'users_id': globalValues.currentUser.documentId,
                'users_displayName': globalValues.currentUser.displayName
              }
            ]
          }).catchError((error) {
            print(error);
          }).then((newPatrolDocument) {
            print(newPatrolDocument.documentID);

            // Add the patrol to the user's patrols
            Firestore.instance
                .collection('users')
                .document(globalValues.currentUser.documentId)
                .updateData({
              'currentPatrol': newPatrolDocument.documentID
            }).catchError((error) {
              print(error);
            });

            globalValues.currentUser.currentPatrol =
                newPatrolDocument.documentID;
            globalValues.reloadMainPageState();
          });
        });
        break;
    }
  }

  Widget _buildNotes() {
    return StreamBuilder(
      stream: notes,
      builder: (context, snapshot) {
        // https://www.youtube.com/watch?v=a6c0R6pcbU8&list=PLgGjX33Qsw-Ha_8ks9im86sLIihimuYrr&index=9
        return snapshot.data == null
            ? Container()
            : ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // Check if the values exist, otherwise use blank strings as values
                  var tempMessage =
                      snapshot.data.documents[index].data['message'] != null
                          ? snapshot.data.documents[index].data['message']
                          : '';
                  var tempUsersDisplayName = snapshot.data.documents[index]
                              .data['users_displayName'] !=
                          null
                      ? snapshot.data.documents[index].data['users_displayName']
                      : '';
                  var tempCreateDate =
                      snapshot.data.documents[index].data['createDate'] != null
                          ? snapshot.data.documents[index].data['createDate']
                              .toDate()
                          : '';

                  // Format date if there is one
                  // https://stackoverflow.com/a/16126580/10021456
                  if (tempCreateDate != '') {
                    var formatter = new DateFormat('HH:mm E');
                    tempCreateDate = formatter.format(tempCreateDate);
                  }

                  return ListTile(
                    title: Text(tempMessage),
                    subtitle: Text(
                      tempUsersDisplayName,
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    trailing: Text(
                      tempCreateDate,
                      style: TextStyle(color: Colors.white30),
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _buildPatrols() {
    return StreamBuilder(
      stream: patrols,
      builder: (context, snapshot) {
        // https://www.youtube.com/watch?v=a6c0R6pcbU8&list=PLgGjX33Qsw-Ha_8ks9im86sLIihimuYrr&index=9
        return snapshot.data == null
            ? Container()
            : ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  // Check if the values exist, otherwise use blank strings as values
                  var tempCreateDate =
                      snapshot.data.documents[index].data['createDate'] != null
                          ? snapshot.data.documents[index].data['createDate']
                              .toDate()
                          : '';
                  var tempEndDate =
                      snapshot.data.documents[index].data['endDate'] != null
                          ? snapshot.data.documents[index].data['endDate']
                              .toDate()
                          : '';
                  var dateForName = tempCreateDate;

                  // Format date if there is one
                  // https://stackoverflow.com/a/16126580/10021456
                  var formatter = new DateFormat('HH:mm');
                  // var formatter = new DateFormat('hh:mm E\nyyyy-MM-dd');
                  if (tempCreateDate != '') {
                    tempCreateDate = formatter.format(tempCreateDate);
                  }
                  if (tempEndDate != '') {
                    tempEndDate = formatter.format(tempEndDate);
                  }
                  var dayNameFormatter = new DateFormat('E');
                  var dayName = dayNameFormatter.format(dateForName);

                  if (tempEndDate != '') {
                    // Patrol has ended
                    return Container(
                      child: ListTile(
                        title: Text(snapshot.data.documents[index].data['users']
                            [0]['users_displayName']),
                        trailing: Text(
                          dayName + '\n' + tempCreateDate + ' - ' + tempEndDate,
                          style: TextStyle(color: Colors.white30),
                        ),
                      ),
                    );
                  } else {
                    // Patrol has not ended
                    return Container(
                      child: ListTile(
                        title: Text(snapshot.data.documents[index].data['users']
                            [0]['users_displayName']),
                        subtitle: Text(
                          'On Patrol',
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        trailing: Text(
                          dayName + '\n' + tempCreateDate,
                          style: TextStyle(color: Colors.white30),
                        ),
                      ),
                    );
                  }
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
            resizeToAvoidBottomPadding: false,
            drawer: DrawerWidget(),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  _onFloatingButtonTapped(
                      DefaultTabController.of(context).index);
                }),
            appBar: AppBar(
              title: Text(selectedGroup),
              bottom: PreferredSize(
                preferredSize: Size(40.0, 40.0),
                child: Container(
                  child: new TabBar(
                    tabs: [
                      Container(
                        height: 40.0,
                        child: Tab(text: 'Notes'),
                      ),
                      Container(
                        height: 40.0,
                        child: Tab(text: 'Patrols'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                (globalValues.currentUser.groups.length > 1) ?
                PopupMenuButton(
                  onSelected: _onSettingsSelected,
                  itemBuilder: (BuildContext context) {
                    return ['Switch Group'].map((String item) {
                      return PopupMenuItem<String>(
                          value: item, child: Text(item));
                    }).toList();
                  },
                ) : Container()
              ],
            ),
            body: TabBarView(
              children: [
                _buildNotes(),
                _buildPatrols(),
              ],
            ),
          );
        }));
  }
}
