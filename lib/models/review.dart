import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

import 'post.dart';

class Review {
  int? id;
  int? postID;
  // int? userID;
  int? createdUserID;
  int? score;
  String? description;
  String? img;
  Post? post;
  User? user;

  Review({
    this.id,
    this.postID,
    // this.userID,
    this.createdUserID,
    this.score,
    this.description,
    this.img,
    this.post,
    this.user,
  });

  static Future<List<dynamic>?> getReviews(String token, int userID) async {
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
          img: t['users_reviews_created']['img_path'],
          post: Post(endName: t['posts']['name_end']),
          user: User(
            firstName: t['users_reviews_created']['first_name'],
            lastName: t['users_reviews_created']['last_name'],
          ),
        );
        reviews.add(review);
      }
      return [reviews, json['avg_review']['_avg']['score']];
    }
    return null;
  }

  // static Future<double?> avgRatingReveiw(String token, int userID) async {
  //   NetworkHelper networkHelper = NetworkHelper('login', {});
  //   var json = await networkHelper.getData(token);
  //   if (json != null && json['error'] == false) {
  //     double avg = json['_avg'];
  //     return avg;
  //   }
  //   return null;
  // }
}
