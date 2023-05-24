import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/contact.dart';
import 'package:chatify/models/message.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  // Adds the message to firebase backend.
  Future<void> addMessageToDb(final Message message) async {
    var map = message.toMap();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);
    addToContacts(senderId: message.senderId, receiverId: message.receiverId);
    await _messageCollection
        .doc(message.receiverId!)
        .collection(message.senderId!)
        .add(map);
  }

  DocumentReference getContactsDocument(
          {final String? of, final String? forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  addToContacts({String? senderId, String? receiverId}) async {
    final Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId!, receiverId!, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    final String senderId,
    final String receiverId,
    final currentTime,
  ) async {
    final DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    final String senderId,
    final String receiverId,
    final currentTime,
  ) async {
    final DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  DocumentReference getBlockedDocument(
          {final String? of, final String? forContact}) =>
      _userCollection.doc(of).collection(BLOCKED_CONTACTS).doc(forContact);

  addToBlockedList({String? senderId, String? receiverId}) async {
    final Timestamp currentTime = Timestamp.now();

    await addToSenderBlockedList(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderBlockedList(
    final String? senderId,
    final String? receiverId,
    final currentTime,
  ) async {
    final DocumentSnapshot senderSnapshot =
        await getBlockedDocument(of: senderId!, forContact: receiverId!).get();

    if (!senderSnapshot.exists) {
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getBlockedDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    } else {
      await getBlockedDocument(of: senderId, forContact: receiverId).delete();
    }
  }

  DocumentReference getMutedDocument(
          {final String? of, final String? forContact}) =>
      _userCollection.doc(of).collection(MUTED_CONTACTS).doc(forContact);

  addToMutedList({String? senderId, String? receiverId}) async {
    final Timestamp currentTime = Timestamp.now();

    await addToSenderMutedList(senderId!, receiverId!, currentTime);
  }

  Future<void> addToSenderMutedList(
    final String senderId,
    final String receiverId,
    final currentTime,
  ) async {
    final DocumentSnapshot senderSnapshot =
        await getMutedDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      final Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getMutedDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    } else {
      await getMutedDocument(of: senderId, forContact: receiverId).delete();
    }
  }

  void setImageMsg(
      final String url, final String receiverId, final String senderId) async {
    final Message message = Message.imageMessage(
        message: Constants.IMAGE,
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: Constants.MESSAGE_TYPE_IMAGE,
        isRead: false);

    // create imagemap
    var map = message.toImageMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  void setVideoMsg(final String? url, final String? receiverId,
      final String? senderId) async {
    final Message message = Message.videoMessage(
        message: "VIDEO",
        receiverId: receiverId,
        senderId: senderId,
        videoUrl: url,
        timestamp: Timestamp.now(),
        type: 'video',
        isRead: false);

    // create imagemap
    var map = message.toVideoMap();

    // var map = Map<String, dynamic>();
    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  void setFileMsg(final String? url, final String? receiverId,
      final String? senderId) async {
    final Message message = Message.fileMessage(
        message: "FILE",
        receiverId: receiverId,
        senderId: senderId,
        fileUrl: url,
        timestamp: Timestamp.now(),
        type: 'file',
        isRead: false);

    var map = message.tofileMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  void setAudioMsg(final String? url, final String? receiverId,
      final String? senderId) async {
    final Message message = Message.audioMessage(
        message: "AUDIO",
        receiverId: receiverId,
        senderId: senderId,
        audioUrl: url,
        timestamp: Timestamp.now(),
        type: 'audio',
        isRead: false);

    var map = message.toAudioMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId!)
        .add(map as Map<String, dynamic>);

    _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId!)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({final String? userId}) =>
      _userCollection.doc(userId).collection(CONTACTS_COLLECTION).snapshots();

  Stream<QuerySnapshot> fetchBlockedUsers({final String? userId}) =>
      _userCollection.doc(userId).collection(BLOCKED_CONTACTS).snapshots();

  Future<bool> isBlocked(final String? userId, final String? receiverId) async {
    final DocumentSnapshot senderSnapshot =
        await getBlockedDocument(of: userId, forContact: receiverId).get();
    if (!senderSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isMuted(final String userId, final String receiverId) async {
    final DocumentSnapshot senderSnapshot =
        await getMutedDocument(of: userId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      return false;
    } else {
      return true;
    }
  }

  Stream<QuerySnapshot> fetchLastMessageBetween({
    required final String senderId,
    required final String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();

  Future<int> unreadMessagesCount({
    required String senderId,
    required String receiverId,
  }) async {
    var c = 0;
    await _messageCollection
        .doc(receiverId)
        .collection(senderId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((documentSnapshot) {
      c = documentSnapshot.docs.length;
    });
    return c;
  }

  void addStatus(final String url, final String senderId) async {
    await _userCollection
        .doc(senderId)
        .collection(STATUS)
        .add({'url': url, 'timestamp': Timestamp.now()});
  }
}
