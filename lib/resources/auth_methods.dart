import 'package:chatify/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/enum/user_state.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/userData.dart';
import 'package:chatify/utils/utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<User> getCurrentUser() async {
    return _auth.currentUser!;
  }

  Future<UserData> getUserDetails() async {
    final User currentUser = await getCurrentUser();

    final DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return UserData.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<UserData?> getUserDetailsById(id) async {
    UserData? userData;
    try {
      final DocumentSnapshot documentSnapshot =
          await _userCollection.doc(id).get();
      userData =
          UserData.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print(e);
    }
    return userData;
  }

  Future<UserCredential?> signIn() async {
    try {
      final GoogleSignInAccount? _signInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication _signInAuthentication =
          await _signInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: _signInAuthentication.accessToken,
          idToken: _signInAuthentication.idToken);

      final UserCredential user = await _auth.signInWithCredential(credential);
      return user;
    } catch (e) {
      print("Auth methods error- ");
      print(e);
      return null;
    }
  }

  Future<bool> authenticateUser(final UserCredential user) async {
    final QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.user!.email)
        .get();
    final List<DocumentSnapshot> docs = result.docs;
    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(final User? currentUser, final String? token) async {
    final String? username = Utils.getUsername(currentUser!.email);
    final UserData user = UserData(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoURL,
      firebaseToken: token,
      username: username,
      firstColor: null,
      secondColor: null,
    );
    firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user) as Map<String, dynamic>);
  }

  Future<List<UserData>> fetchAllUsers(final User currentUser) async {
    final List<UserData> userList = [];
    final QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserData.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Future<List<String>> fetchAllFriends(final User curruser) async {
    final List<String> userList = [];
    final QuerySnapshot querySnapshot =
        await _userCollection.doc(curruser.uid).collection(Constants.FOLLOWING).get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      userList.add(querySnapshot.docs[i][Constants.CONTACT_ID]);
    }

    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void setUserState(
      {required final String userId, required final UserState userState}) {
    final int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({required final String uid}) =>
      _userCollection.doc(uid).snapshots();

  Stream<QuerySnapshot> getFriends({String? uid}) =>
      _userCollection.doc(uid).collection("following").snapshots();

  Stream<QuerySnapshot> getFriendsStatus({String? uid}) =>
      _userCollection.doc(uid).collection("following").snapshots();

  Future<void> addFriend(
      final String? currUserId, final String? followingUserId) async {
    final Contact follower =
        Contact(uid: followingUserId, addedOn: Timestamp.now());
    var senderMap = follower.toMap(follower);
    await _userCollection
        .doc(currUserId)
        .collection('following')
        .doc(followingUserId)
        .set(senderMap as Map<String, dynamic>);

    final Contact following =
        Contact(uid: currUserId, addedOn: Timestamp.now());
    var receiverMap = following.toMap(following);
    return _userCollection
        .doc(followingUserId)
        .collection("followers")
        .doc(currUserId)
        .set(receiverMap as Map<String, dynamic>);
  }

  Future<void> removeFriend(
      final String? currUserId, final String? followingUserId) async {
    await _userCollection
        .doc(currUserId)
        .collection("following")
        .doc(followingUserId)
        .delete();

    return _userCollection
        .doc(followingUserId)
        .collection("followers")
        .doc(currUserId)
        .delete();
  }
}
