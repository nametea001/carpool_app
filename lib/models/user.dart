import 'dart:convert';

import 'package:car_pool_project/services/networking.dart';

class User {
  final int? userID;
  final String? username;
  final int? userRoleID;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? userRoleName;
  User({
    this.userID,
    this.username,
    this.userRoleID,
    this.firstName,
    this.lastName,
    this.email,
    this.userRoleName,
  });

  static Future<User?> checkLogin(String username, String password) async {
    NetworkHelper networkHelper = NetworkHelper('login', {});
    var json = await networkHelper.postData(jsonEncode(<String, String>{
      'username': username,
      'password': password,
    }));

    if (json != null && json['error'] == false) {
      Map u = json['user'];
      User user = User(
        userID: u["id"],
        username: u["username"],
        firstName: u["first_name"],
        lastName: u["last_name"],
        email: u["email"],
        userRoleID: u["user_role_id"],
        userRoleName: u["user_roles"]["user_role_name"],
      );
      return user;
    }
    return null;
  }
}
