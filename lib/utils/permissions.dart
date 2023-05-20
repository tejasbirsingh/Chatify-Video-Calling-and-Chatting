import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class Permissions {

  static Future<bool> cameraAndMicrophonePermissionsGranted() async {

    PermissionStatus? cameraPermissionStatus = await _getCameraPermission();
    PermissionStatus? microphonePermissionStatus =
        await _getMicrophonePermission();

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus!);
      return false;
    }
    
  }

  static Future<bool> recordingPermission() async {
    PermissionStatus? microphonePermissionStatus =
        await _getMicrophonePermission();

    if (microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      _handleRecordInvalidPermission(microphonePermissionStatus!);
      return false;
    }
  }

  static Future<PermissionStatus?> _getCameraPermission() async {
    if (await Permission.camera.request().isGranted) {}
 
// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    return statuses[Permission.camera];
//     PermissionStatus permission =
//         await Permission.checkPermissionStatus(Permission.camera);
//     if (permission != PermissionStatus.granted &&
//         permission != PermissionStatus.denied) {
//       Map<Permission, PermissionStatus> permissionStatus =await [
//   Permission.camera,

// ].request();

//       return permissionStatus[Permission.camera] ??
//           PermissionStatus.restricted;
//     } else {
//       return permission;
//     }
  }

  static Future<PermissionStatus?> _getMicrophonePermission() async {
    bool permission = await Permission.microphone.isGranted;
    Map<Permission, PermissionStatus>? permissionStatus;
    if (!permission) {
      permissionStatus = await [
        Permission.microphone,
      ].request();
      return permissionStatus![Permission.microphone] ??
        PermissionStatus.restricted;
    }
    return null;
  }

  static void _handleRecordInvalidPermission(
    PermissionStatus microphonePermissionStatus,
  ) {
    if (microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  static void _handleInvalidPermissions(
    PermissionStatus? cameraPermissionStatus,
    PermissionStatus microphonePermissionStatus,
  ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw new PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }
}
