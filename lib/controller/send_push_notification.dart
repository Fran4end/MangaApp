import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../constants.dart';
import '../model/manga.dart';

class SendPushNotification {
  static final Dio dio = Dio(BaseOptions(baseUrl: "https://fcm.googleapis.com"));

  init() {
    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  Future<void> sendPushNotification(String token, Manga manga) async {
    if (true) {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var body = {
        "message": {
          "topic": "news",
          "notification": {
            "title": "New Chapter",
            "body": "New chapter of ${manga.title} available.",
          },
          "data": {"manga": manga.toJson()},
          "android": {
            "notification": {"click_action": "TOP_STORY_ACTIVITY"}
          },
          "apns": {
            "payload": {
              "aps": {"category": "NEW_MESSAGE_CATEGORY"}
            }
          }
        }
      };
      dio.post(
        "/v1/projects/manga-bec41/message:send",
        options: Options(headers: headers),
        data: jsonEncode(body),
      );
    }
  }
}
