import '../services/networking.dart';
import 'chat.dart';
import 'chat_detail.dart';
import 'user.dart';

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

  static Future<List<Chat>?> getChatFromChatUserLog(String token) async {
    NetworkHelper networkHelper = NetworkHelper('chat_user_logs/get_chats', {});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      List<Chat> chats = [];
      for (Map c in json['chat_user_logs']) {
        Chat chat = Chat(
          id: c['id'],
          chatType: c['chat_type'],
          sendUserID: c['send_user_id'],
          sendPostID: c['send_post_id'],
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
          chatDetail: ChatDetail(
            msgType: c['chat_details'][0]['msg_type'],
            msg: c['chat_details'][0]['msg'],
            createdUserID: c['chat_details'][0]['created_user_id'],
          ),
          chatUserLog: ChatUserLog(count: c['_count']['chat_user_logs']),
          createdAt:
              c['created_at'] != null ? DateTime.parse(c['created_at']) : null,
        );
        chats.add(chat);
      }
      return chats;
    }
    return null;
  }
}
