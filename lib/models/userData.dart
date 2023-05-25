import 'package:chatify/constants/constants.dart';

class UserData {
  String? uid;
  String? name;
  String? email;
  String? username;
  String? status;
  int? state;
  String? profilePhoto;
  String? firebaseToken;
  int? firstColor;
  int? secondColor;
  bool? hasStatus;

  UserData(
      {this.uid,
      this.name,
      this.email,
      this.username,
      this.status,
      this.state,
      this.profilePhoto,
      this.firebaseToken,
      this.firstColor,
      this.secondColor,
      this.hasStatus});

  Map toMap(UserData user) {
    var data = Map<String, dynamic>();
    data[Constants.UID] = user.uid;
    data[Constants.NAME] = user.name;
    data[Constants.EMAIL] = user.email;
    data[Constants.USER_NAME] = user.username;
    data[Constants.STATUS] = user.status;
    data[Constants.STATE] = user.state;
    data[Constants.PROFILE_PHOTO] = user.profilePhoto;
    data[Constants.FIREBASE_TOKEN] = user.firebaseToken;
    data[Constants.FIRST_COLOR] = user.firstColor;
    data[Constants.SECOND_COLOR] = user.secondColor;
    data[Constants.HAS_STATUS] = user.hasStatus;
    return data;
  }

  // Named constructor
  UserData.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData[Constants.UID];
    this.name = mapData[Constants.NAME];
    this.email = mapData[Constants.EMAIL];
    this.username = mapData[Constants.USER_NAME];
    this.status = mapData[Constants.STATUS];
    this.state = mapData[Constants.STATE];
    this.profilePhoto = mapData[Constants.PROFILE_PHOTO];
    this.firebaseToken = mapData[Constants.FIREBASE_TOKEN];
    this.firstColor = mapData[Constants.FIRST_COLOR];
    this.secondColor = mapData[Constants.SECOND_COLOR];
    this.hasStatus = mapData[Constants.HAS_STATUS];
  }
}
