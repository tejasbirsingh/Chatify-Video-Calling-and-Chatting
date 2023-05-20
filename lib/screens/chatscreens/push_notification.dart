 import 'dart:convert';

import 'package:chatify/configs/firebase_config.dart';
import 'package:http/http.dart' as http;

Future<http.Response> sendNotification(
      String message, String sender, String receiver) async {
Uri uri = Uri(path:  'https://fcm.googleapis.com/fcm/send');
    return await http.post(uri
     ,
      headers: <String, String>{
        'Authorization': 'key=$SERVER_KEY',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        // "message": {
        "to": "$receiver",
        "collapse_key": "type_a",
        "priority": "high",
        "alert": "true",
        "id": '1',
        "notification": {
          "title": "$sender",
          "body": "$message",
        },
        "data": {
          "title": "$sender",
          "body": "$message",
          "sound": "default",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
        // }
      }),
    );
  }