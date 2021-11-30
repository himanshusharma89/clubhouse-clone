import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TokenService {
  static const tokenURL = "https://prod-in.100ms.live/hmsapi/himanshu.app.100ms.live/api/token";
  
  static const defaultRole = "listener";

  static Future<String?> getToken({required String userId, required String roomId, String? role}) async {
    http.Response response = await http.post(Uri.parse(tokenURL),
        body: {'room_id': roomId, 'user_id': userId, 'role': role ?? defaultRole});
    debugPrint("Response " + response.body.toString());
    var body = json.decode(response.body);
    return body['token'];
  }
}
