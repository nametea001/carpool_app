import 'dart:convert';

import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class Report {
  int? id;
  int? reasonID;
  int? userID;
  int? postID;
  int? reviewID;
  String? description;

  Report({
    this.id,
    this.reasonID,
    this.userID,
    this.postID,
    this.reviewID,
    this.description,
  });

  static Future<bool?> addReport(Report reportData) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('reports/add_report', {});
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{
          "reason_id": reportData.reasonID,
          "user_id": reportData.userID,
          "post_id": reportData.postID,
        }),
        token);
    if (json != null && json['error'] == false) {
      return true;
    }
    return null;
  }
}
