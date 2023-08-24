// import 'dart:convert';
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

  static Future<List<types.Message>?> getChatDetails(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('chatDetails', {});
    List<types.Message> chatDetails = [];
    var json = await networkHelper.getData(token);

    if (json != null && json['error'] == false) {
      for (Map t in json['chat_details']) {
        types.Message chatDetail = types.TextMessage(
            author: types.User(
                id: t['created_user_id'],
                firstName: t['users']['first_name'],
                lastName: t['users']['first_name']),
            id: t['id'],
            type: types.MessageType.text,
            status: types.Status.seen,
            text: t['msg'],
            createdAt: DateTime.parse(t['created_at']).millisecondsSinceEpoch);
        chatDetails.add(chatDetail);
      }
      return chatDetails;
    }
    return null;
  }
}
