import 'dart:convert';

import '../services/networking.dart';

class Chat {
  int? id;
  String? chatType;
  int? sendUserID;
  int? sendPostID;
  String? img;

  Chat({this.id, this.chatType, this.sendUserID, this.sendPostID, this.img});

  static Future<List<Chat>?> getChats(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('chats', {});
    List<Chat> chats = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['chats']) {
        Chat chat = Chat();
        chats.add(chat);
      }
      return chats;
    }
    return null;
  }

  static Future<Chat?> startChat(String token, Chat chat) async {
    NetworkHelper networkHelper = NetworkHelper('chats/start_chat', {});
    var json =
        await networkHelper.postData(jsonEncode(<String, dynamic>{}), token);

    if (json != null && json['error'] == false) {
      Map t = json['chat'];
      Chat chat = Chat(id: t['id']);
      return chat;
    }
    return null;
  }
}
