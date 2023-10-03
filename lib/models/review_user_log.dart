import 'package:prefs/prefs.dart';

import '../services/networking.dart';
import 'post.dart';

class ReviewUserLog {
  int? id;
  int? userID;
  int? postID;
  Post? post;
  // int? count;

  ReviewUserLog({
    this.id,
    this.userID,
    this.postID,
    this.post,
    // this.count,
  });

  static Future<int?> getCountReviewUserLog() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper =
        NetworkHelper('review_user_logs/count_review', {});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['review_user_log'];
      // ReviewUserLog chat = ReviewUserLog(
      //   count: t['_count'],
      // );
      return t['_count'];
    }
    return null;
  }
}
