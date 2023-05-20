import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chatify/enum/user_state.dart';

class Utils {
  static String getUsername(String? email) {
    return "live:${email!.split('@')[0]}";
  }

  static String getInitials(String? name) {
    if (name != null) {
      final List<String> nameSplit = name.split(" ");
      final String firstNameInitial = nameSplit[0][0];
      final String lastNameInitial =
          nameSplit.length > 1 ? nameSplit[1][0] : "";
      return lastNameInitial != ""
          ? firstNameInitial + lastNameInitial
          : firstNameInitial;
    }
    return "";
  }

  static Future<File?> pickImage({required ImageSource source}) async {
    final XFile? selectedImage = await ImagePicker().pickImage(source: source);
    if (selectedImage != null) {
      File? img = File(selectedImage.path);
      return await compressImage(img);
    }
    return null;
  }

  static Future<File?> compressImage(File? imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    final int rand = Random().nextInt(10000);

    final Im.Image? image = Im.decodeImage(imageToCompress!.readAsBytesSync());
    Im.copyResize(image!, width: 500, height: 500);

    return new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;
      case UserState.Online:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;
      case 1:
        return UserState.Online;
      default:
        return UserState.Waiting;
    }
  }

  static String formatDateString(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    var formatter = DateFormat('dd/MM/yy');
    return formatter.format(dateTime);
  }

  static String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}
