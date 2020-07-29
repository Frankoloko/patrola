import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String documentId;
  String displayName;
  String phoneNumber;
  DocumentReference firebaseDocumentReference;
  List<dynamic> groups;
  String currentPatrol;

  User(this.documentId, this.displayName, this.phoneNumber, firebaseDocumentReference, this.groups);
}