import 'dart:convert';

import 'package:car_pool_project/models/review_user_log.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';
import 'post.dart';
import 'post_detail.dart';
import 'user.dart';

class Review {
  int? id;
  int? postID;
  int? userID;
  int? createdUserID;
  int? score;
  String? description;
  Post? post;
  User? user;

  Review({
    this.id,
    this.postID,
    this.userID,
    this.createdUserID,
    this.score,
    this.description,
    this.post,
    this.user,
  });

  static Future<List<dynamic>?> getReviews(int userID) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
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
          post: Post(endName: t['posts']['name_end']),
          user: User(
            firstName: t['users_reviews_created']['first_name'],
            lastName: t['users_reviews_created']['last_name'],
            img: t['users_reviews_created']['img_path'],
          ),
        );
        reviews.add(review);
      }
      return [reviews, json['avg_review']['_avg']['score']];
    }
    return null;
  }

  static Future<List<dynamic>?> getMyReviews(String token) async {
    NetworkHelper networkHelper = NetworkHelper('reviews/my_review', {});
    List<Review> reviews = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['reviews']) {
        Review review = Review(
          id: t['id'],
          score: t['score'],
          description: t['description'],
          post: Post(
              id: t['posts']['id'],
              startName: t['posts']['name_start'],
              endName: t['posts']['name_end'],
              startDistrictID: t['posts']['start_district_id'],
              endDistrictID: t['posts']['end_district_id'],
              countPostMember: t['posts']['_count']['post_members'],
              status: t['posts']['status'],
              createdUserID: t['posts']['created_user_id'],
              dateTimeStart: t['posts']['date_time_start'] != null
                  ? DateTime.parse(t['posts']['date_time_start'])
                  : null,
              dateTimeBack: t['posts']['date_time_back'] != null
                  ? DateTime.parse(t['posts']['date_time_back'])
                  : null,
              postDetail: PostDetail(
                  price: double.parse(t['posts']['post_details'][0]['price']),
                  seat: t['posts']['post_details'][0]['seat']),
              user: User(
                firstName: t['posts']['users']['first_name'],
                lastName: t['posts']['users']['last_name'],
                email: t['posts']['users']['email'],
                sex: t['posts']['users']['sex'],
                img: t['posts']['users']['img_path'],
              )),
        );
        reviews.add(review);
      }
      List<ReviewUserLog> reviewUserLogs = [];
      for (Map r in json['review_user_logs']) {
        var t = r['posts'];
        ReviewUserLog reviewUserLog = ReviewUserLog(
            id: r['id'],
            post: Post(
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
                )));
        reviewUserLogs.add(reviewUserLog);
      }
      return [reviews, reviewUserLogs];
    }
    return null;
  }

  static Future<Review?> addReview(
      String token, int reviewUserLogID, Review review) async {
    NetworkHelper networkHelper = NetworkHelper('reviews/add_review',
        {"review_user_log_id": reviewUserLogID.toString()});
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{
          "post_id": review.postID,
          "user_id": review.userID,
          "score": review.score,
          "description": review.description,
        }),
        token);
    if (json != null && json['error'] == false) {
      Map t = json['review'];
      Review review = Review(
        id: t['id'],
        score: t['score'],
        description: t['description'],
        post: Post(
            id: t['posts']['id'],
            startName: t['posts']['name_start'],
            endName: t['posts']['name_end'],
            startDistrictID: t['posts']['start_district_id'],
            endDistrictID: t['posts']['end_district_id'],
            countPostMember: t['posts']['_count']['post_members'],
            status: t['posts']['status'],
            createdUserID: t['posts']['created_user_id'],
            dateTimeStart: t['posts']['date_time_start'] != null
                ? DateTime.parse(t['posts']['date_time_start'])
                : null,
            dateTimeBack: t['posts']['date_time_back'] != null
                ? DateTime.parse(t['posts']['date_time_back'])
                : null,
            postDetail: PostDetail(
                price: double.parse(t['posts']['post_details'][0]['price']),
                seat: t['posts']['post_details'][0]['seat']),
            user: User(
              firstName: t['posts']['users']['first_name'],
              lastName: t['posts']['users']['last_name'],
              email: t['posts']['users']['email'],
              sex: t['posts']['users']['sex'],
              img: t['posts']['users']['img_path'],
            )),
      );
      return review;
    }
    return null;
  }

  static Future<Review?> editMyReview(String token, Review review) async {
    NetworkHelper networkHelper = NetworkHelper('reviews/edit_review', {});
    var json = await networkHelper.putData(
        jsonEncode(<String, dynamic>{
          "review_id": review.id,
          "score": review.score,
          "description": review.description,
        }),
        token);
    if (json != null && json['error'] == false) {
      Map t = json['review'];
      Review review = Review(
        id: t['id'],
        score: t['score'],
        description: t['description'],
        post: Post(
            id: t['posts']['id'],
            startName: t['posts']['name_start'],
            endName: t['posts']['name_end'],
            startDistrictID: t['posts']['start_district_id'],
            endDistrictID: t['posts']['end_district_id'],
            countPostMember: t['posts']['_count']['post_members'],
            status: t['posts']['status'],
            createdUserID: t['posts']['created_user_id'],
            dateTimeStart: t['posts']['date_time_start'] != null
                ? DateTime.parse(t['posts']['date_time_start'])
                : null,
            dateTimeBack: t['posts']['date_time_back'] != null
                ? DateTime.parse(t['posts']['date_time_back'])
                : null,
            postDetail: PostDetail(
                price: double.parse(t['posts']['post_details'][0]['price']),
                seat: t['posts']['post_details'][0]['seat']),
            user: User(
              firstName: t['posts']['users']['first_name'],
              lastName: t['posts']['users']['last_name'],
              email: t['posts']['users']['email'],
              sex: t['posts']['users']['sex'],
              img: t['posts']['users']['img_path'],
            )),
      );
      return review;
    }
    return null;
  }
}
