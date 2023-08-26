// import 'dart:convert';
import 'package:car_pool_project/models/chat.dart';

import '../services/networking.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatDetail {
  // int? id;
  // int? chatID;
  // String? msgType;
  // String? msg;
  // LatLng? latLng;

  // ChatDetail({
  //   this.id,
  //   this.chatID,
  //   this.msgType,
  //   this.msg,
  //   this.latLng,
  // });

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
      Chat chat = Chat(id: c['id']);

      return [chat, chatDetails];
    }
    return null;
  }
}
