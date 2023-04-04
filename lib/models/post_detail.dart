import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  });

  static Future<List<PostDetail>?> getPostDetails(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('postDetails', {});
    List<PostDetail> postDetails = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['postDetails']) {
        PostDetail postDetail = PostDetail(
          id: t['id'],
          postID: t['post_id'],
          // startLatLng: LatLng(t['lat']),
          // endLatLng: LatLng(t['lat']),
          description: t['description'],
          brand: t['brand'],
          model: t['model'],
          vehicleRegistration: t['vehicle_registration'],
          color: t['color'],
        );
        postDetails.add(postDetail);
      }
      return postDetails;
    }
    return null;
  }

  static Future<List<PostDetail>?> addPostDetails(
    String token,
    PostDetail postDetail,
  ) async {
    NetworkHelper networkHelper =
        NetworkHelper('post_detail/add_post_detail', {});
    List<PostDetail> postDetails = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['postDetails']) {
        PostDetail postDetail = PostDetail(
          id: t['id'],
          postID: t['post_id'],
          // startLatLng: LatLng(t['lat']),
          // endLatLng: LatLng(t['lat']),
          description: t['description'],
          brand: t['brand'],
          model: t['model'],
          vehicleRegistration: t['vehicle_registration'],
          color: t['color'],
        );
        postDetails.add(postDetail);
      }
      return postDetails;
    }
    return null;
  }
}
