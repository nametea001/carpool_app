// import 'dart:convert';
import 'package:car_pool_project/models/chat.dart';
import 'package:car_pool_project/models/user.dart';

import '../services/networking.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatDetail {
  int? id;
  int? chatID;
  String? msgType;
  String? msg;
  // LatLng? latLng;

  ChatDetail({
    this.id,
    this.chatID,
    this.msgType,
    this.msg,
    // this.latLng,
  });

  static Future<List<types.Message>?> getChatDetails(
      String token, Chat chat) async {
    NetworkHelper networkHelper = NetworkHelper('chat_details/${chat.id}', {});
    var json = await networkHelper.getData(token);

    if (json != null && json['error'] == false) {
      List<types.Message> chatDetails = [];
      for (Map t in json['chat_details']) {
        types.Message chatDetail = types.TextMessage(
            author: types.User(
                id: t['created_user_id'].toString(),
                firstName: t['users']['first_name'],
                lastName: t['users']['first_name']),
            id: t['id'].toString(),
            type: t['msg_type'] == "MSG"
                ? types.MessageType.text
                : types.MessageType.image,
            status: types.Status.seen,
            text: t['msg'],
            createdAt: DateTime.parse(t['created_at']).millisecondsSinceEpoch);
        chatDetails.add(chatDetail);
      }
      return chatDetails;
    }
    return null;
  }

  static Future<dynamic> startChatDetails(String token, Chat chat) async {
    NetworkHelper networkHelper = NetworkHelper('chat_details/start_chat', {
      "chat_type": chat.chatType,
      "send_user_id": chat.sendUserID.toString(),
      "send_post_id": chat.sendPostID.toString(),
    });
    List<types.Message> chatDetails = [];
    var json = await networkHelper.getData(token);

    if (json != null && json['error'] == false) {
      for (Map t in json['chat_details']) {
        types.Message chatDetail = types.TextMessage(
            author: types.User(
                id: t['created_user_id'].toString(),
                firstName: t['users']['first_name'],
                lastName: t['users']['first_name']),
            id: t['id'].toString(),
            type: t['msg_type'] == "MSG"
                ? types.MessageType.text
                : types.MessageType.image,
            status: types.Status.seen,
            text: t['msg'],
            createdAt: DateTime.parse(t['created_at']).millisecondsSinceEpoch);
        chatDetails.add(chatDetail);
      }
      Map c = json['chat'];
      Chat chat = Chat(
        id: c['id'],
        chatType: c['chat_type'],
        sendUserID: c['send_user_id'] ?? null,
        sendPostID: c['send_post_id'] ?? null,
        createdUserID: c['created_user_id'],
        sendUser: c['send_user'] == null
            ? User()
            : User(
                firstName: c['send_user']['first_name'],
                lastName: c['send_user']['last_name'],
                img: c['send_user']['img_path'],
              ),
        createdUser: c['created_user'] == null
            ? null
            : User(
                firstName: c['created_user']['first_name'],
                lastName: c['created_user']['last_name'],
                img: c['created_user']['img_path'],
              ),
      );

      return [chat, chatDetails];
    }
    return null;
  }
}
