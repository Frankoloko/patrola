import 'package:Patrola/global-values.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Patrola/dialogs/dialog-input.dart';
import '../../models/group-model.dart';

class GroupsFindPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupsFindPageState();
  }
}

class _GroupsFindPageState extends State<GroupsFindPage> {
  final TextEditingController _textController = TextEditingController();
  List _groups = [];
  List _filteredGroups = [];

  @override
  void initState() {
    _getGroups();
    super.initState();
  }

  _getGroups() {
    Firestore.instance
        .collection('groups')
        .orderBy('name')
        .getDocuments()
        .then((response) {
      setState(() {
        _groups = response.documents;
        print(response.documents[0].data['name']);
        _filterGroups();
      });
    });
  }

  _filterGroups() {
    if (_textController.text.isEmpty && _groups.length > 0) {
      setState(() {
        _filteredGroups = _groups;
      });
    } else {
      setState(() {
        _filteredGroups = _groups
            .where((item) => item.data['name']
                .toLowerCase()
                .contains(_textController.text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _textController.addListener(_filterGroups);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: _textController,
          style: TextStyle(color: Colors.white),
          decoration: new InputDecoration(
            hintStyle: TextStyle(color: Colors.white),
            hintText: 'Search...',
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _textController.clear();
            },
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredGroups.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              ListTile(
                title: Text(_filteredGroups[index].data['name'] != null
                    ? _filteredGroups[index].data['name']
                    : ''),
                onTap: () {
                  _sendInvitation(index);
                },
              ),
              // ListSeparatorWidget() // Use or not?
            ],
          );
        },
      ),
    );
  }

  _sendInvitation(int index) async {
    // DON'T DELETE THIS, IT WILL BE NEEDED IN THE FUTURE FOR SURE
    // asyncInputDialog(
    //         context: context,
    //         inputText: 'Hi there. I would like to join your Patrola group.',
    //         keyboardType: TextInputType.text,
    //         title: 'Send Access Request',
    //         doneText: 'Send',
    //         placeholder: 'A message for the group admins')
    //     .then((response) {
    //   print(response);
    // });

    // The is only temporary until a request=allow process is in place
      // Add the group to the user's groups list
        currentUser.groups.add(_filteredGroups[index].data['name']);
        Firestore.instance.collection('users').document(currentUser.documentId).updateData({
            'displayName': currentUser.displayName,
            'phoneNumber': currentUser.phoneNumber,
            'groups': currentUser.groups
        });

      // Add the user to the group's members list
        var tempGroup = await Firestore.instance
            .collection('groups')
            .where('name', isEqualTo: _filteredGroups[index].data['name'])
            .getDocuments();

        await Firestore.instance
            .collection('groups')
            .document(tempGroup.documents[0].documentID)
            .collection('members')
            .document(currentUser.documentId).setData(
             {'users_displayName': currentUser.displayName, 'isAdmin': true}); 
     
        setState(() {});

      Navigator.pushNamed(context, '/groups');
  }
}
