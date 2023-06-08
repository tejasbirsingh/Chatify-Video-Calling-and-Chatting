import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/call.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String? uid}) =>
      callCollection.doc(uid).snapshots();

  Future<bool> makeCall({final Call? call}) async {
    try {
      call!.hasDialled = true;
      final Map<String, dynamic> hasDialledMap = call.toMap(call);
      call.hasDialled = false;
      final Map<String, dynamic> hasNotDialledMap = call.toMap(call);
      await callCollection.doc(call.callerId).set(hasDialledMap);
      await callCollection.doc(call.receiverId).set(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({final Call? call}) async {
    try {
      await callCollection.doc(call!.callerId).delete();
      await callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
