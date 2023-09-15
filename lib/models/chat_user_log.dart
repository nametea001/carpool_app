import '../services/networking.dart';

class ChatUserLog {
  int? id;
  int? chatID;
  int? userID;
  int? count;
  // Chat? chat;

  ChatUserLog({
    this.id,
    this.chatID,
    this.userID,
    this.count,
    // this.chat,
  });

  static Future<ChatUserLog?> getCountChatUserLog(
    String token,
  ) async {
    NetworkHelper networkHelper =
        NetworkHelper('chat_user_logs/count_user', {});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['chat_user_log'];
      ChatUserLog chat = ChatUserLog(
        count: t['_count'],
      );
      return chat;
    }
    return null;
  }

  static Future<bool?> deleteChatUserLog(String token, int chatID) async {
    NetworkHelper networkHelper =
        NetworkHelper('chat_user_logs/delete_chat_log/$chatID', {});
    var json = await networkHelper.deleteData(token);
    if (json != null && json['error'] == false) {
      return true;
    }
    return null;
  }
}
