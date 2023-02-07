import 'dart:convert';

import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Post {
  final int? id;
  final int? startAmphireID;
  final String? startAmphireName;
  final int? startProvinceID;
  final String? startProvinceName;
  final int? endAmphireID;
  final String? endAmphireName;
  final int? endProvinceID;
  final String? endProvinceName;
  final String? img;

  Post({
    this.id,
    this.startAmphireID,
    this.startAmphireName,
    this.startProvinceID,
    this.startProvinceName,
    this.endAmphireID,
    this.endAmphireName,
    this.endProvinceID,
    this.endProvinceName,
    this.img,
  });

  static Future<List<Post>?> getPost(
    String username,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('posts', {
      'device': "mobile",
    });
    List<Post> posts = [];
    var json = await networkHelper.getData();
    if (json != null && json['error'] == false) {
      for (Map t in json['posts']) {
        Post post = Post(
            id: t['id'],
            startAmphireID: t['start_amphure_id'],
            startAmphireName: t['start_thai_amphures']['name_th'],
            startProvinceID: t['start_thai_amphures']['thai_provinces']['id'],
            startProvinceName: t['start_thai_amphures']['thai_provinces']
                ['name_th'],
            endAmphireID: t['end_amphure_id'],
            endAmphireName: t['end_thai_amphures']['name_th'],
            endProvinceID: t['end_thai_amphures']['thai_provinces']['id'],
            endProvinceName: t['end_thai_amphures']['thai_provinces']
                ['name_th'],
            img: t['img']);
        posts.add(post);
      }
      return posts;
    }
    return null;
  }

  static Future<List<Post>?> postPosts(User user) async {
    NetworkHelper networkHelper = NetworkHelper('post', {
      'user_id': user.userID.toString(),
    });
    List<Post> posts = [];
    var json = await networkHelper.postData(jsonEncode(<String, dynamic>{
      'user_id': user.userID.toString(),
    }));
    if (json != null && json['error'] == false) {
      for (Map t in json['post']) {
        Post post = Post();
        posts.add(post);
      }
      return posts;
    } else if (json != null && json['error'] == true) {
      return null;
    }
    return null;
  }
}
