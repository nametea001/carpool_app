import 'package:car_pool_project/models/chat_detail.dart';
import 'package:car_pool_project/models/chat_user_log.dart';
import 'package:car_pool_project/models/user.dart';

import '../services/networking.dart';
import 'post.dart';

class Chat {
  int? id;
  String? chatType;
  int? sendUserID;
  int? sendPostID;
  // String? img;
  int? createdUserID;
  ChatUserLog? chatUserLog;
  User? sendUser;
  User? createdUser;
  Post? post;
  ChatDetail? chatDetail;
  DateTime? createdAt;
  String? img;
  DateTime? updatedAt;

  Chat({
    this.id,
    this.chatType,
    this.sendUserID,
    this.sendPostID,
    // this.img,
    this.createdUserID,
    this.chatUserLog,
    this.sendUser,
    this.createdUser,
    this.post,
    this.chatDetail,
    this.createdAt,
    this.updatedAt,
    this.img,
  });

  static Future<List<Chat>?> getChats(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('chats', {});
    List<Chat> chats = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map c in json['chats']) {
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
            chatDetail: ChatDetail(
              msgType: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['msg_type'],
              msg: c['chat_details'].isEmpty
                  ? "เริ่มการสนทนา"
                  : c['chat_details'][0]['msg'],
              createdUserID: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['created_user_id'],
            ),
            chatUserLog: ChatUserLog(count: c['_count']['chat_user_logs']),
            createdAt: c['created_at'] != null
                ? DateTime.parse(c['created_at'])
                : null,
            updatedAt: c['updated_at'] != null
                ? DateTime.parse(c['updated_at'])
                : null,
          );
          chats.add(chat);
        } else {
          Chat chat = Chat(
            id: c['id'],
            chatType: c['chat_type'],
            sendUserID: c['send_user_id'],
            sendPostID: c['send_post_id'],
            createdUserID: c['created_user_id'],
            chatDetail: ChatDetail(
              msgType: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['msg_type'],
              msg: c['chat_details'].isEmpty
                  ? "เริ่มการสนทนา"
                  : c['chat_details'][0]['msg'],
              createdUserID: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['created_user_id'],
            ),
            chatUserLog: ChatUserLog(count: c['_count']['chat_user_logs']),
            createdAt: c['created_at'] != null
                ? DateTime.parse(c['created_at'])
                : null,
            post: Post(
              startName: c['posts']['name_start'],
              endName: c['posts']['name_end'],
            ),
            img: "non_img.png",
          );
          chats.add(chat);
        }
      }

      return chats;
    }
    return null;
  }

  static Future<List<Chat>?> getChatFromChatUserLog(String token) async {
    NetworkHelper networkHelper = NetworkHelper('chat_user_logs/get_chats', {});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      List<Chat> chats = [];
      for (Map c in json['chat_user_logs']['chats']) {
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
            chatDetail: ChatDetail(
              msgType: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['msg_type'],
              msg: c['chat_details'].isEmpty
                  ? "เริ่มการสนทนา"
                  : c['chat_details'][0]['msg'],
              createdUserID: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['created_user_id'],
            ),
            chatUserLog: ChatUserLog(count: c['_count']['chat_user_logs']),
            createdAt: c['created_at'] != null
                ? DateTime.parse(c['created_at'])
                : null,
          );
          chats.add(chat);
        } else {
          Chat chat = Chat(
            id: c['id'],
            chatType: c['chat_type'],
            sendUserID: c['send_user_id'],
            sendPostID: c['send_post_id'],
            createdUserID: c['created_user_id'],
            chatDetail: ChatDetail(
              msgType: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['msg_type'],
              msg: c['chat_details'].isEmpty
                  ? "เริ่มการสนทนา"
                  : c['chat_details'][0]['msg'],
              createdUserID: c['chat_details'].isEmpty
                  ? null
                  : c['chat_details'][0]['created_user_id'],
            ),
            chatUserLog: ChatUserLog(count: c['_count']['chat_user_logs']),
            createdAt: c['created_at'] != null
                ? DateTime.parse(c['created_at'])
                : null,
            post: Post(
              startName: c['posts']['name_start'],
              endName: c['posts']['name_end'],
            ),
            img: "non_img.png",
          );
          chats.add(chat);
        }
      }
      return chats;
    }
    return null;
  }
}
