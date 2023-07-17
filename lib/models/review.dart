import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Review {
  int? id;
  int? postID;
  int? userID;
  int? score;

  Review({
    this.id,
    this.postID,
    this.userID,
    this.score,
  });

  static Future<List<Review>?> getReviews(String token, int userID) async {
    NetworkHelper networkHelper = NetworkHelper('reviews', {
      "user_id": userID.toString(),
    });
    List<Review> reviews = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['reviews']) {
        Review review = Review(
          id: t['id'],
        );
        reviews.add(review);
      }
      return reviews;
    }
    return null;
  }
}
