import 'dart:convert';

import 'package:car_pool_project/models/post_detail.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class Post {
  int? id;
  String? startName;
  String? endName;
  int? startDistrictID;
  int? startProvinceID;
  int? endDistrictID;
  int? endProvinceID;
  int? countPostMember;
  int? createdUserID;
  DateTime? dateTimeStart;
  DateTime? dateTimeBack;
  String? status;
  bool? isBack;
  PostDetail? postDetail;
  // user
  User? user;

  Post({
    this.id,
    this.startName,
    this.endName,
    this.startDistrictID,
    this.startProvinceID,
    this.endDistrictID,
    this.endProvinceID,
    this.countPostMember,
    this.createdUserID,
    this.dateTimeStart,
    this.dateTimeBack,
    this.status,
    this.isBack,
    this.postDetail,
    this.user,
  });

  static Future<List<Post>?> getPosts(String token, Post post) async {
    String strDatetimeStart = post.dateTimeStart == null
        ? DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())
        : DateFormat("yyyy-MM-dd HH:mm:ss").format(post.dateTimeStart!);
    String? strDatetimeEnd = post.dateTimeBack != null
        ? DateFormat("yyyy-MM-dd HH:mm:ss").format(post.dateTimeBack!)
        : null;

    NetworkHelper networkHelper = NetworkHelper('posts', {
      "start_province_id": post.startProvinceID.toString(),
      "start_district_id": post.startDistrictID.toString(),
      "end_province_id": post.endProvinceID.toString(),
      "end_district_id": post.endDistrictID.toString(),
      "date_time_start": strDatetimeStart.toString(),
      "date_time_back": strDatetimeEnd.toString(),
      "is_back": post.isBack.toString()
    });
    List<Post> posts = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['posts']) {
        Post post = Post(
            id: t['id'],
            startName: t['name_start'],
            endName: t['name_end'],
            startDistrictID: t['start_district_id'],
            // startProvinceID: t['start_district']['provinces']['id'],
            endDistrictID: t['end_district_id'],
            // endProvinceID: t['end_district']['provinces']['id'],
            countPostMember: t['_count']['post_members'],
            status: t['status'],
            createdUserID: t['created_user_id'],
            dateTimeStart: t['date_time_start'] != null
                ? DateTime.parse(t['date_time_start'])
                : null,
            dateTimeBack: t['date_time_back'] != null
                ? DateTime.parse(t['date_time_back'])
                : null,
            postDetail: PostDetail(
                price: double.parse(t['post_details'][0]['price']),
                seat: t['post_details'][0]['seat']),
            user: User(
              firstName: t['users']['first_name'],
              lastName: t['users']['last_name'],
              email: t['users']['email'],
              sex: t['users']['sex'],
              img: t['users']['img_path'],
            ));
        posts.add(post);
      }
      return posts;
    }
    return null;
  }

  static Future<Post?>? getPostByID(String token, int postID) async {
    NetworkHelper networkHelper =
        NetworkHelper('get_post_by_id', {"post_id": postID.toString()});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['posts'];
      Post post = Post(
          id: t['id'],
          startName: t['name_start'],
          endName: t['name_end'],
          startDistrictID: t['start_district_id'],
          endDistrictID: t['end_district_id'],
          countPostMember: t['_count']['post_members'],
          status: t['status'],
          createdUserID: t['created_user_id'],
          dateTimeStart: t['date_time_start'] != null
              ? DateTime.parse(t['date_time_start'])
              : null,
          dateTimeBack: t['date_time_back'] != null
              ? DateTime.parse(t['date_time_back'])
              : null,
          postDetail: PostDetail(
              price: double.parse(t['post_details'][0]['price']),
              seat: t['post_details'][0]['seat']),
          user: User(
            firstName: t['users']['first_name'],
            lastName: t['users']['last_name'],
            email: t['users']['email'],
            sex: t['users']['sex'],
            img: t['users']['img_path'],
          ));

      return post;
    }
    return null;
  }

  static Future<List<Post>?> getPostsHistory(String token) async {
    NetworkHelper networkHelper = NetworkHelper('posts/history', {});
    List<Post> posts = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['posts']) {
        Post post = Post(
            id: t['id'],
            startName: t['name_start'],
            endName: t['name_end'],
            startDistrictID: t['start_district_id'],
            endDistrictID: t['end_district_id'],
            countPostMember: t['_count']['post_members'],
            status: t['status'],
            createdUserID: t['created_user_id'],
            dateTimeStart: t['date_time_start'] != null
                ? DateTime.parse(t['date_time_start'])
                : null,
            dateTimeBack: t['date_time_back'] != null
                ? DateTime.parse(t['date_time_back'])
                : null,
            postDetail: PostDetail(
                price: double.parse(t['post_details'][0]['price']),
                seat: t['post_details'][0]['seat']),
            user: User(
              firstName: t['users']['first_name'],
              lastName: t['users']['last_name'],
              email: t['users']['email'],
              sex: t['users']['sex'],
              img: t['users']['img_path'],
            ));
        posts.add(post);
      }
      return posts;
    }
    return null;
  }

  static Future<Post?> addPostAndPostDetail(
      String token, Post dataPost, PostDetail dataPostDetail) async {
    NetworkHelper networkHelper = NetworkHelper('posts/add_post', {});

    String? dateTImeStart =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(dataPost.dateTimeStart!);
    String? dateTimeBack = dataPost.isBack == true
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dataPost.dateTimeBack!)
        : null;

    var latLngStart = dataPostDetail.startLatLng!.toJson();
    var latLngend = dataPostDetail.endLatLng!.toJson();

    var json = await networkHelper.postData(
      jsonEncode(<String, dynamic>{
        "name_start": dataPost.startName,
        "name_end": dataPost.endName,
        "start_district_id": dataPost.startDistrictID,
        "end_district_id": dataPost.endDistrictID,
        "is_back": dataPost.isBack,
        "date_time_start": dateTImeStart,
        "date_time_back": dateTimeBack,
        // "status": dataPost.status,
        "lat_lng_start": latLngStart,
        "lat_lng_end": latLngend,
        "seat": dataPostDetail.seat,
        "price": dataPostDetail.price,
        "description": dataPostDetail.description,
        "brand": dataPostDetail.brand,
        "model": dataPostDetail.model,
        "vehicle_registration": dataPostDetail.vehicleRegistration,
        "color": dataPostDetail.color,
      }),
      token,
    );
    if (json != null && json['error'] == false) {
      Map t = json['post'];
      Post post = Post(
        id: t['id'],
        startName: t['name_start'],
        endName: t['name_end'],
        createdUserID: t['created_user_id'],
        dateTimeStart: t['date_time_start'] != null
            ? DateTime.parse(t['date_time_start'])
            : null,
        dateTimeBack: t['date_time_back'] != null
            ? DateTime.parse(t['date_time_back'])
            : null,
        isBack: t['isback'],
        postDetail: PostDetail(
          price: double.parse(t['post_details'][0]['price']),
          seat: t['post_details'][0]['seat'],
          description: t['post_details'][0]['description'],
          brand: t['post_details'][0]['brand'],
          model: t['post_details'][0]['model'],
          vehicleRegistration: t['post_details'][0]['vehicle_registration'],
          color: t['post_details'][0]['color'],
          startLatLng: t['post_details'][0]['lat_lng_start'] != null
              ? LatLng(t['post_details'][0]['lat_lng_start'][0],
                  t['post_details'][0]['lat_lng_start'][1])
              : null,
          endLatLng: t['post_details'][0]['lat_lng_end'] != null
              ? LatLng(t['post_details'][0]['lat_lng_end'][0],
                  t['post_details'][0]['lat_lng_end'][1])
              : null,
        ),
        user: User(
          firstName: t['users']['first_name'],
          lastName: t['users']['last_name'],
          sex: t['users']['sex'],
          email: t['users']['email'],
          img: t['users']['img_path'],
        ),
      );
      return post;
    }
    return null;
  }

  static Future<Post?> updateStatusPost(
      String token, int postID, String status) async {
    NetworkHelper networkHelper = NetworkHelper('posts/update_status', {});

    var json = await networkHelper.putData(
      jsonEncode(<String, dynamic>{"post_id": postID, "status": status}),
      token,
    );
    if (json != null && json['error'] == false) {
      Map t = json['post'];
      Post post = Post(id: t['id'], status: t['status']);
      return post;
    }
    return null;
  }
}
