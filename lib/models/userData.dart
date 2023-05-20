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
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['username'] = user.username;
    data["status"] = user.status;
    data["state"] = user.state;
    data["profile_photo"] = user.profilePhoto;
    data["firebase_token"] = user.firebaseToken;
    data["first_color"] = user.firstColor;
    data["second_color"] = user.secondColor;
    data["hasstatus"] = user.hasStatus;
    return data;
  }

  // Named constructor
  UserData.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.status = mapData['status'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
    this.firebaseToken = mapData['firebase_token'];
    this.firstColor = mapData["first_color"];
    this.secondColor = mapData["second_color"];
    this.hasStatus = mapData["hasstatus"];
  }
}
