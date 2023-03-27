import 'dart:convert';

import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:intl/intl.dart';

class Post {
  final int? id;
  final int? startDistrictID;
  final String? startAmphireName;
  final int? startProvinceID;
  final String? startProvinceName;
  final int? endDistrictID;
  final String? endAmphireName;
  final int? endProvinceID;
  final String? endProvinceName;
  final String? img;
  final int? seat;
  final int? seatFull;
  final double? price;

  Post({
    this.id,
    this.startDistrictID,
    this.startAmphireName,
    this.startProvinceID,
    this.startProvinceName,
    this.endDistrictID,
    this.endAmphireName,
    this.endProvinceID,
    this.endProvinceName,
    this.img,
    this.seat,
    this.seatFull,
    this.price,
  });

  static Future<List<Post>?> getPost(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('posts', {
      'device': "mobile",
    });
    List<Post> posts = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['posts']) {
        Post post = Post(
            id: t['id'],
            startDistrictID: t['start_district_id'],
            startAmphireName: t['start_district']['name_th'],
            startProvinceID: t['start_district']['provinces']['id'],
            startProvinceName: t['start_district']['provinces']['name_th'],
            endDistrictID: t['end_district_id'],
            endAmphireName: t['end_district']['name_th'],
            endProvinceID: t['end_district']['provinces']['id'],
            endProvinceName: t['end_district']['provinces']['name_th'],
            seat: t['seat'],
            seatFull: t['seat_full'],
            price: double.parse(t['price']),
            img: t['img']);
        posts.add(post);
      }
      return posts;
    }
    return null;
  }

  // static Future<List<Post>?> postPosts(User user) async {
  //   NetworkHelper networkHelper = NetworkHelper('post', {
  //     'user_id': user.userID,
  //   });
  //   List<Post> posts = [];
  //   var json = await networkHelper.postData(jsonEncode(<String, dynamic>{
  //     'user_id': user.userID,
  //   }));
  //   if (json != null && json['error'] == false) {
  //     for (Map t in json['post']) {
  //       Post post = Post();
  //       posts.add(post);
  //     }
  //     return posts;
  //   }
  //   return null;
  // }
}
