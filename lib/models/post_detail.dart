import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/post_member.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prefs/prefs.dart';

import 'user.dart';

class PostDetail {
  int? id;
  int? postID;
  int? seat;
  double? price;
  LatLng? startLatLng;
  LatLng? endLatLng;
  String? description;
  String? brand;
  String? model;
  String? vehicleRegistration;
  String? color;
  int? createdUserId;
  Post? post;

  PostDetail({
    this.id,
    this.postID,
    this.seat,
    this.price,
    this.startLatLng,
    this.endLatLng,
    this.description,
    this.brand,
    this.model,
    this.vehicleRegistration,
    this.color,
    this.createdUserId,
    this.post,
  });

  static Future<List<PostDetail>?> getPostDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('posts_detail', {});
    List<PostDetail> postDetails = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['postDetails']) {
        PostDetail postDetail = PostDetail(
          id: t['id'],
          postID: t['post_id'],
          startLatLng: t['lat_lng_start'] != null
              ? LatLng(t['lat_lng_start'][0], t['lat_lng_start'][1])
              : null,
          endLatLng: t['lat_lng_end'] != null
              ? LatLng(t['lat_lng_end'][0], t['lat_lng_end'][1])
              : null,
          seat: t['seat'],
          price: t['price'] != null ? double.parse(t['price']) : null,
          description: t['description'],
          brand: t['brand'],
          model: t['model'],
          vehicleRegistration: t['vehicle_registration'],
        );
        postDetails.add(postDetail);
      }
      return postDetails;
    }
    return null;
  }

  static Future<dynamic> getPostDetailByPostID(int postID) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper =
        NetworkHelper('post_details', {"post_id": postID.toString()});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['post_detail'];
      PostDetail postDetail = PostDetail(
          id: t['id'],
          postID: t['post_id'],
          startLatLng: t['lat_lng_start'] != null
              ? LatLng(t['lat_lng_start'][0], t['lat_lng_start'][1])
              : null,
          endLatLng: t['lat_lng_end'] != null
              ? LatLng(t['lat_lng_end'][0], t['lat_lng_end'][1])
              : null,
          description: t['description'],
          seat: t['seat'],
          price: t['price'] != null ? double.parse(t['price']) : null,
          brand: t['brand'],
          model: t['model'],
          vehicleRegistration: t['vehicle_registration'],
          color: t['color'],
          post: Post(
            status: t['posts']['status'],
            countPostMember: t['posts']['_count']['post_members'],
            dateTimeStart: t['posts']['date_time_start'] != null
                ? DateTime.parse(t['posts']['date_time_start'])
                : null,
            dateTimeBack: t['posts']['date_time_back'] != null
                ? DateTime.parse(t['posts']['date_time_back'])
                : null,
            isBack: t['posts']['is_back'],
            startName: t['posts']['name_start'],
            endName: t['posts']['name_end'],
            createdUserID: t['posts']['created_user_id'],
            user: User(
              firstName: t['posts']['users']['first_name'],
              lastName: t['posts']['users']['last_name'],
              sex: t['posts']['users']['sex'],
              email: t['posts']['users']['email'],
              img: t['posts']['users']['img_path'],
            ),
          ));
      List<PostMember> postMembers = [];
      for (Map pm in json['post_detail']['posts']['post_members']) {
        PostMember postMember = PostMember(
            id: pm['id'],
            userID: pm['user_id'],
            user: User(
              firstName: pm['users']['first_name'],
              lastName: pm['users']['last_name'],
              email: pm['users']['email'],
              sex: pm['users']['sex'],
              img: t['posts']['users']['img_path'],
            ));
        postMembers.add(postMember);
      }

      return [postDetail, postMembers];
    }
    return null;
  }
}
