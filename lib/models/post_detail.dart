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
  int? createdUserId;

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
  });

  static Future<List<PostDetail>?> getPostDetails(
    String token,
  ) async {
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

  static Future<PostDetail?> getPostDetailByPostID(
      String token, int postID) async {
    NetworkHelper networkHelper = NetworkHelper('post_details/${postID}', {});
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
      );

      return postDetail;
    }
    return null;
  }
}
