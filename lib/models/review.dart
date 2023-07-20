import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Review {
  int? id;
  int? postID;
  // int? userID;
  int? createdUserID;
  int? score;
  String? description;
  String? img;
  String? endName;
  User? user;

  Review({
    this.id,
    this.postID,
    // this.userID,
    this.createdUserID,
    this.score,
    this.description,
    this.img,
    this.endName,
    this.user,
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
          score: t['score'],
          description: t['description'],
          img: t['img'],
          endName: t['posts']['end_district']['name_th'],
          user: User(
            firstName: t['users_reviews_created']['first_name'],
            lastName: t['users_reviews_created']['last_name'],
          ),
        );
        reviews.add(review);
      }
      return reviews;
    }
    return null;
  }
}
