library patrola.globals;

import 'package:Patrola/dialogs/dialog-message.dart';
import 'package:flutter/material.dart';
import './models/user-model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:Patrola/dialogs/dialog-input.dart';

final currentUser = new User('', '', '', '', []);
var reloadMainPageState;
var showLoadingAnimation = false;
var currentGroupId;

void getUserGroups() async {
  // Find all the groups this user is linked to
  final userGroupsIds = await Firestore.instance
      .collection('group-members')
      .where('userId', isEqualTo: currentUser.documentId)
      .getDocuments();

  // Put each groupId in an array
  List groupIds = [];
  userGroupsIds.documents.forEach((value) {
    groupIds.add(value.data['groupId']);
  });

  print(groupIds);

  final userGroups = await Firestore.instance
      .collection('groups')
      .where('userId', isEqualTo: currentUser.documentId)
      .getDocuments() as List;

  // print(userGroups.documents[0].data);
}

Future reloadUserDetails(BuildContext context) async {
  // Get the current user
  final FirebaseUser savedUser = await FirebaseAuth.instance.currentUser();
  String phoneNumberWithSpaces = savedUser.phoneNumber.substring(0, 3) +
      ' ' +
      savedUser.phoneNumber.substring(3, 5) +
      ' ' +
      savedUser.phoneNumber.substring(5, 8) +
      ' ' +
      savedUser.phoneNumber.substring(8, 12);

  // Find a user in the db with the same phone number
  final fetchedUser = await Firestore.instance
      .collection('users')
      .where('phoneNumber', isEqualTo: phoneNumberWithSpaces)
      .getDocuments();

  // If a user is found, set the global values and get the user's groups
  if (fetchedUser.documents.length > 0) {
    currentUser.documentId = fetchedUser.documents[0].documentID;
    currentUser.displayName = fetchedUser.documents[0].data['displayName'];
    currentUser.phoneNumber = phoneNumberWithSpaces;
    currentUser.groups = new List<dynamic>.from(fetchedUser.documents[0].data['groups']);

    // Set the current user's active patrol if there is any
    if (fetchedUser.documents[0].data['currentPatrol'] != null) {
      currentUser.currentPatrol = fetchedUser.documents[0].data['currentPatrol'];
    }
    
    // Set the reference for future use
    currentUser.firebaseDocumentReference = fetchedUser.documents[0].reference;

    // getUserGroups();
    return;
  }

  // If a user is not found, create a new one by asking for a display name and save the user details in global values, and get the user's groups
  asyncInputDialog(
          context: context,
          keyboardType: TextInputType.text,
          title: 'Enter your display name',
          doneText: 'Save',
          placeholder: 'Usually your first and last name',
          cantCancel: true)
      .then((response) {
    Firestore.instance.collection('users').add({
      'displayName': response,
      'phoneNumber': phoneNumberWithSpaces,
      'vehicles': [],
      'groups': []
    }).catchError((error) {
      print(error);
    }).then((user) {
      currentUser.documentId = user.documentID;
      currentUser.displayName = response;
      currentUser.phoneNumber = phoneNumberWithSpaces;
      currentUser.firebaseDocumentReference = user;
      Navigator.pushReplacementNamed(context, '/groups');
      asyncMessageDialog(context: context, text: 'You don\'t belong to any patrolling groups yet. Use the top right menu to Create or Find a group.');
    });
    // getUserGroups();
  });
}

contactUs(BuildContext context) {
  asyncMessageDialog(context: context, title: 'Contact Us', text: 'For help, complaints, suggestions, feedback, advertisements, business or anything else! Send us a message and we will get back to you as soon as possible.').then((x) {
    asyncInputDialog(context: context, title: 'Your Message').then((value) {
      if (value == null) return;

      Firestore.instance.collection('contact-us').add({
        'userDocumentId': currentUser.documentId,
        'userDisplayName': currentUser.displayName,
        'userPhoneNumber': currentUser.phoneNumber,
        'message': value
      });
    });
  });
}