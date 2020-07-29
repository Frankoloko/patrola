import 'package:Patrola/global-values.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Patrola/other/drawer-widget.dart';
import 'package:Patrola/dialogs/dialog-yesno.dart';
import 'package:Patrola/dialogs/dialog-list.dart';
import 'package:Patrola/dialogs/dialog-input.dart';
import 'package:Patrola/dialogs/dialog-message.dart';

import '../../global-values.dart' as globalValues;

class GroupsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupsPageState();
  }
}

class _GroupsPageState extends State<GroupsPage> {
  Stream users;
  String selectedGroup = '';
  bool thisUserIsAdmin = true;

  @override
  void initState() {
    if (currentUser.groups.length > 0) {
      _changeGroup(currentUser.groups[0]);
    }
    super.initState();
  }

  void _changeGroup(String newValue) async {
    // Get the new group's members subcollection
    var tempGroup = await Firestore.instance
        .collection('groups')
        .where('name', isEqualTo: newValue)
        .getDocuments();

    globalValues.currentGroupId = tempGroup.documents[0].documentID;

    this.users = Firestore.instance
        .collection('groups')
        .document(globalValues.currentGroupId)
        .collection('members')
        .snapshots();

    this.selectedGroup = newValue;
    setState(() {});
  }

  void _settingsSelected(String selectedItem) {
    switch (selectedItem) {
      case 'Switch Group':
        asyncListDialog(context: context, options: currentUser.groups)
            .then((value) {
          if (value != null) _changeGroup(value);
        });
        break;
      case 'Create Group':
        asyncInputDialog(
                context: context,
                title: 'Create New Group',
                placeholder: 'Group name',
                keyboardType: TextInputType.text)
            .then((groupName) async {
          // Check if the group name already exists
          var tempExistGroup = await Firestore.instance
              .collection('groups')
              .where('lowercaseName', isEqualTo: groupName.toLowerCase())
              .getDocuments();
          if (tempExistGroup.documents.length > 0) {
            return asyncMessageDialog(
                    context: context,
                    text: 'A group with that name already exists')
                .then((response) {
              asyncInputDialog(
                  context: context,
                  inputText: groupName,
                  title: 'Create New Group',
                  placeholder: 'Group name',
                  keyboardType: TextInputType.text);
            });
          }

          // Add new group to database
          var batch = Firestore.instance.batch();

          // Create the group
          var newGroup = Firestore.instance.collection('groups').document();
          batch.setData(newGroup,
              {'name': groupName, 'lowercaseName': groupName.toLowerCase()});

          // Create the new members subcollection
          var newMember =
              newGroup.collection('members').document(currentUser.documentId);
          batch.setData(newMember,
              {'users_displayName': currentUser.displayName, 'isAdmin': true});

          // Add this group to the user's group list
          currentUser.groups.add(groupName);
          if (currentUser.groups.length == 1) _changeGroup(currentUser.groups[0]);

          batch.setData(currentUser.firebaseDocumentReference, {
            'displayName': currentUser.displayName,
            'phoneNumber': currentUser.phoneNumber,
            'groups': currentUser.groups
          });

          // Commit the batch edits
          batch.commit().catchError((err) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
              err,
              style: TextStyle(color: Colors.black),
            )));
          }).then((response) {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
              'New group created',
              style: TextStyle(color: Colors.black),
            )));
          });
        });
        break;
      case 'Find Group':
        Navigator.pushNamed(context, '/groups/find');
        break;
      case 'Leave Group':
        asyncYesNoDialog(
                context: context,
                title: 'Leave Group',
                bodyText: 'Are you sure you want to leave the group ' +
                    selectedGroup +
                    '?')
            .then((response) async {
          if (response) {
            // Remove the group from the user's groups list
            Firestore.instance
                .collection('users')
                .document(currentUser.documentId)
                .updateData({
              'groups': FieldValue.arrayRemove([selectedGroup])
            });

            // Remove the groups.members record also
            var tempGroup = await Firestore.instance
                .collection('groups')
                .where('name', isEqualTo: selectedGroup)
                .getDocuments();

            await Firestore.instance
                .collection('groups')
                .document(tempGroup.documents[0].documentID)
                .collection('members')
                .document(currentUser.documentId)
                .delete();

            // Could be a firebase function, but I am adding it here for now
            // Delete the group if there are no members left in it
            var tempMembers = await Firestore.instance
                .collection('groups')
                .document(tempGroup.documents[0].documentID)
                .collection('members')
                .getDocuments();

            if (tempMembers.documents.length < 1) {
              Firestore.instance
                  .collection('groups')
                  .document(tempGroup.documents[0].documentID)
                  .delete();
            }

            currentUser.groups.remove(selectedGroup);
            if (currentUser.groups.length > 0) {
              _changeGroup(currentUser.groups[0]);
            } else {
              selectedGroup = '';
            }

            setState(() {});
          }
        });
        break;
    }
  }

  Widget _deleteButton(DocumentSnapshot document) {
    // Don't show an admin button for one self
    if (document.documentID == currentUser.documentId) return Container();

    // If the user isn't an admin, don't allow deleting
    if (!thisUserIsAdmin) return Container();

    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Colors.white54,
      ),
      onPressed: () {
        asyncYesNoDialog(
                context: context,
                title: 'Delete User',
                bodyText: 'Remove ' +
                    document.data['users_displayName'] +
                    ' from this group?')
            .then((response) {
          if (!response) return;

          Firestore.instance
              .collection('users')
              .document(document.documentID)
              .updateData({
            'groups': FieldValue.arrayRemove([selectedGroup])
          });
          Firestore.instance
              .collection('groups')
              .document(globalValues.currentGroupId)
              .collection('members')
              .document(document.documentID)
              .delete();
        });
      },
    );
  }

  Widget _toggleAdminButton(DocumentSnapshot document) {
    // Don't show an admin button for one self
    if (document.documentID == currentUser.documentId) return Container();

    if (document.data['isAdmin']) {
      // Is admin user
      return RaisedButton(
        child: Text('Admin'),
        color: Theme.of(context).accentColor,
        textColor: Colors.black,
        onPressed: () {
          // Remove admin rights from the user
          Firestore.instance
              .collection('groups')
              .document(globalValues.currentGroupId)
              .collection('members')
              .document(document.documentID)
              .updateData({'isAdmin': !document.data['isAdmin']});
          setState(() {
            // document.data['isAdmin'] = !document.data['isAdmin'];
          });
        },
      );
    } else {
      // Is NOT admin user
      return FlatButton(
        child: Text(
          'Admin',
          style: TextStyle(
            color: Colors.white30,
          ),
        ),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.all(Radius.circular(2.0))),
        onPressed: () {
          // Remove admin rights from the user
          Firestore.instance
              .collection('groups')
              .document(globalValues.currentGroupId)
              .collection('members')
              .document(document.documentID)
              .updateData({'isAdmin': !document.data['isAdmin']});
          setState(() {
            // document.data['isAdmin'] = !document.data['isAdmin'];
          });
        },
      );
    }
  }

  Widget _adminLabel(DocumentSnapshot document) {
    // Is admin user
    if (document.data['isAdmin'])
      return Text('Admin',
          style: TextStyle(color: Theme.of(context).accentColor));
    // Is NOT admin user
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(selectedGroup),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: _settingsSelected,
            itemBuilder: (BuildContext context) {
              return (currentUser.groups.length > 1) ? [
                'Switch Group',
                'Create Group',
                'Find Group',
                'Leave Group'
              ].map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList() : [
                'Create Group',
                'Find Group',
                'Leave Group'
              ].map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList();
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: users,
        builder: (context, snapshot) {
          return snapshot.data == null
              ? Container()
              : ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                          snapshot.data.documents[index]['users_displayName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          thisUserIsAdmin
                              ? _toggleAdminButton(
                                  snapshot.data.documents[index])
                              : _adminLabel(snapshot.data.documents[index]),
                          _deleteButton(snapshot.data.documents[index]),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
