// import 'dart:convert';
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:car_pool_project/models/chat.dart';
import 'package:car_pool_project/models/user.dart';

import '../services/networking.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'post.dart';

class ChatDetail {
  int? id;
  int? chatID;
  String? msgType;
  String? msg;
  int? createdUserID;
  // LatLng? latLng;

  ChatDetail({
    this.id,
    this.chatID,
    this.msgType,
    this.msg,
    this.createdUserID,
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
      "chat_type": chat.chatType.toString(),
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
      if (c['chat_type'] == "PRIVATE") {
        Chat chat = Chat(
          id: c['id'],
          chatType: c['chat_type'],
          sendUserID: c['send_user_id'],
          sendPostID: c['send_post_id'],
          createdUserID: c['created_user_id'],
          sendUser: User(
            firstName: c['send_user']['first_name'],
            lastName: c['send_user']['last_name'],
            img: c['send_user']['img_path'],
          ),
          createdUser: User(
            firstName: c['created_user']['first_name'],
            lastName: c['created_user']['last_name'],
            img: c['created_user']['img_path'],
          ),
        );

        return [chat, chatDetails];
      } else {
        Chat chat = Chat(
          id: c['id'],
          chatType: c['chat_type'],
          sendPostID: c['send_post_id'],
          post: Post(
            startName: c['posts']['name_start'],
            endName: c['posts']['name_end'],
          ),
          img: "non_img.png",
        );

        return [chat, chatDetails];
      }
    }
    return null;
  }

  static Future<types.TextMessage?> sendMessage(
      String token, ChatDetail chatDetail, Chat chat) async {
    NetworkHelper networkHelper =
        NetworkHelper('chat_details/send_message', {});

    var json = await networkHelper.postData(
      jsonEncode(<String, dynamic>{
        "chat_id": chatDetail.chatID,
        "msg_type": chatDetail.msgType,
        "msg": chatDetail.msg,
        "chat_type": chat.chatType,
        "send_user_id": chat.sendUserID,
        "created_user_id": chat.createdUserID,
        "send_post_id": chat.sendPostID,
      }),
      token,
    );
    if (json != null && json['error'] == false) {
      Map t = json['chat_detail'];
      types.TextMessage chatDetail = types.TextMessage(
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
      return chatDetail;
    }
    return null;
  }

  static Future<types.TextMessage?> acceptMessage(
      int userID, String dataAccept) async {
    var json = jsonDecode(dataAccept);
    if (json['user_id'] != userID && json['error'] == false) {
      Map t = json['chat_detail'];
      types.TextMessage chatDetail = types.TextMessage(
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
      return chatDetail;
    }
    return null;
  }
}
