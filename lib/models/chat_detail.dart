// import 'dart:convert';
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:car_pool_project/models/chat.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:prefs/prefs.dart';

import '../services/networking.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'post.dart';
import 'package:car_pool_project/global.dart' as globals;

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

  static Future<List<types.Message>?> getChatDetails(Chat chat) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('chat_details/${chat.id}', {});
    var json = await networkHelper.getData(token);

    if (json != null && json['error'] == false) {
      List<types.Message> chatDetails = [];
      for (Map t in json['chat_details']) {
        String? urlImage;
        if (t['users']['img_path'] != "non_img.png") {
          urlImage =
              "${globals.protocol}${globals.serverIP}/profiles/${t['users']['img_path']}";
        } else {
          urlImage = null;
        }
        if (t['msg_type'] == "MSG") {
          types.Message chatDetail = types.TextMessage(
            author: types.User(
              id: t['created_user_id'].toString(),
              firstName: t['users']['first_name'],
              lastName: t['users']['first_name'],
              imageUrl: urlImage,
            ),
            id: t['id'].toString(),
            type: types.MessageType.text,
            status: types.Status.seen,
            text: t['msg'],
            createdAt: (DateTime.parse(t['created_at']))
                .subtract(const Duration(hours: 7))
                .millisecondsSinceEpoch,
          );
          chatDetails.add(chatDetail);
        } else {
          var imgDetail =
              await networkHelper.getImageDetailsChatDeatil(t['msg']);
          types.ImageMessage chatDetail = types.ImageMessage(
            author: types.User(
              id: t['created_user_id'].toString(),
              firstName: t['users']['first_name'],
              lastName: t['users']['first_name'],
              imageUrl: urlImage,
            ),
            id: t['id'].toString(),
            name: imgDetail!.name,
            size: imgDetail.sizeInKB,
            uri: imgDetail.imageUrl,
            height: imgDetail.height,
            width: imgDetail.width,
            type: types.MessageType.image,
            status: types.Status.seen,
            createdAt: (DateTime.parse(t['created_at']))
                .subtract(const Duration(hours: 7))
                .millisecondsSinceEpoch,
          );
          chatDetails.add(chatDetail);
        }
      }
      return chatDetails;
    }
    return null;
  }

  static Future<dynamic> startChatDetails(Chat chat) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('chat_details/start_chat', {
      "chat_type": chat.chatType.toString(),
      "send_user_id": chat.sendUserID.toString(),
      "send_post_id": chat.sendPostID.toString(),
    });
    List<types.Message> chatDetails = [];
    var json = await networkHelper.getData(token);

    if (json != null && json['error'] == false) {
      for (Map t in json['chat_details']) {
        String? urlImage;
        if (t['users']['img_path'] != "non_img.png") {
          urlImage =
              "${globals.protocol}${globals.serverIP}/profiles/${t['users']['img_path']}";
        } else {
          urlImage = null;
        }
        types.Message chatDetail = types.TextMessage(
          author: types.User(
            id: t['created_user_id'].toString(),
            firstName: t['users']['first_name'],
            lastName: t['users']['first_name'],
            imageUrl: urlImage,
          ),
          id: t['id'].toString(),
          type: t['msg_type'] == "MSG"
              ? types.MessageType.text
              : types.MessageType.image,
          status: types.Status.seen,
          text: t['msg'],
          createdAt: (DateTime.parse(t['created_at']))
              .subtract(const Duration(hours: 7))
              .millisecondsSinceEpoch,
        );
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
      ChatDetail chatDetail, Chat chat) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
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
      String? urlImage;
      if (t['users']['img_path'] != "non_img.png") {
        urlImage =
            "${globals.protocol}${globals.serverIP}/profiles/${t['users']['img_path']}";
      } else {
        urlImage = null;
      }
      types.TextMessage chatDetail = types.TextMessage(
        author: types.User(
          id: t['created_user_id'].toString(),
          firstName: t['users']['first_name'],
          lastName: t['users']['first_name'],
          imageUrl: urlImage,
        ),
        id: t['id'].toString(),
        type: t['msg_type'] == "MSG"
            ? types.MessageType.text
            : types.MessageType.image,
        status: types.Status.seen,
        text: t['msg'],
        createdAt: (DateTime.parse(t['created_at']))
            .subtract(const Duration(hours: 7))
            .millisecondsSinceEpoch,
      );
      return chatDetail;
    }
    return null;
  }

  static Future<types.ImageMessage?> sendFile(
      ChatDetail chatDetail, Chat chat, File file) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('chat_details/send_image', {
      "chat_id": chatDetail.chatID.toString(),
      "msg_type": "IMG",
      "chat_type": chat.chatType.toString(),
      "send_user_id": chat.sendUserID.toString(),
      "created_user_id": chat.createdUserID.toString(),
      "send_post_id": chat.sendPostID.toString(),
    });
    var json = await networkHelper.postUpload(token, file);
    if (json != null && json['error'] == false) {
      Map t = json['chat_detail'];
      String? urlImage;
      if (t['users']['img_path'] != "non_img.png") {
        urlImage =
            "${globals.protocol}${globals.serverIP}/profiles/${t['users']['img_path']}";
      } else {
        urlImage = null;
      }
      var imgDetail = await networkHelper.getImageDetailsChatDeatil(t['msg']);
      types.ImageMessage chatDetail = types.ImageMessage(
        author: types.User(
          id: t['created_user_id'].toString(),
          firstName: t['users']['first_name'],
          lastName: t['users']['first_name'],
          imageUrl: urlImage,
        ),
        id: t['id'].toString(),
        name: imgDetail!.name,
        size: imgDetail.sizeInKB,
        uri: imgDetail.imageUrl,
        height: imgDetail.height,
        width: imgDetail.width,
        type: types.MessageType.image,
        status: types.Status.seen,
        createdAt: (DateTime.parse(t['created_at']))
            .subtract(const Duration(hours: 7))
            .millisecondsSinceEpoch,
      );
      return chatDetail;
    }
    return null;
  }

  static Future<dynamic> acceptMessage(int userID, String dataAccept) async {
    var json = jsonDecode(dataAccept);
    if (json['user_id'] != userID && json['error'] == false) {
      Map t = json['chat_detail'];
      String? urlImage;
      if (t['users']['img_path'] != "non_img.png") {
        urlImage =
            "${globals.protocol}${globals.serverIP}/profiles/${t['users']['img_path']}";
      } else {
        urlImage = null;
      }
      if (t['msg_type'] == "MSG") {
        types.TextMessage chatDetail = types.TextMessage(
          author: types.User(
            id: t['created_user_id'].toString(),
            firstName: t['users']['first_name'],
            lastName: t['users']['first_name'],
            imageUrl: urlImage,
          ),
          id: t['id'].toString(),
          type: types.MessageType.text,
          status: types.Status.seen,
          text: t['msg'],
          createdAt: DateTime.parse(t['created_at']).millisecondsSinceEpoch,
        );
        return chatDetail;
      } else {
        NetworkHelper networkHelper = NetworkHelper('', {});
        var imgDetail = await networkHelper.getImageDetailsChatDeatil(t['msg']);
        types.ImageMessage chatDetail = types.ImageMessage(
          author: types.User(
            id: t['created_user_id'].toString(),
            firstName: t['users']['first_name'],
            lastName: t['users']['first_name'],
            imageUrl: urlImage,
          ),
          id: t['id'].toString(),
          name: imgDetail!.name,
          size: imgDetail.sizeInKB,
          uri: imgDetail.imageUrl,
          height: imgDetail.height,
          width: imgDetail.width,
          type: types.MessageType.image,
          status: types.Status.seen,
          createdAt: DateTime.parse(t['created_at']).millisecondsSinceEpoch,
        );
        return chatDetail;
      }
    }
    return null;
  }
}

class ImageDetails {
  final String name;
  final double sizeInKB;
  final double width;
  final double height;
  final String imageUrl;

  ImageDetails({
    required this.name,
    required this.sizeInKB,
    required this.width,
    required this.height,
    required this.imageUrl,
  });
}
