import 'dart:convert';

import 'package:car_pool_project/services/networking.dart';

class User {
  int? userID;
  String? username;
  int? userRoleID;
  String? firstName;
  String? lastName;
  String? email;
  String? userRoleName;
  String? img;
  String? jwt;
  User({
    this.userID,
    this.username,
    this.userRoleID,
    this.firstName,
    this.lastName,
    this.email,
    this.userRoleName,
    this.img,
    this.jwt,
  });

  static Future<User?> checkLogin(String username, String password) async {
    NetworkHelper networkHelper = NetworkHelper('login', {
      'device': "mobile",
    });
    var json = await networkHelper.postData(
      jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
      }),
      "",
    );

    if (json != null && json['error'] == false && json['token'] != null) {
      Map u = json['user'];
      User user = User(
        userID: u["id"],
        username: u["username"],
        firstName: u["first_name"],
        lastName: u["last_name"],
        email: u["email"],
        userRoleID: u["user_role_id"],
        userRoleName: u["user_roles"]["user_role_name"],
        img: u['img'],
        jwt: json['token'],
      );
      return user;
    }
    return null;
  }

  static Future<User?> signUp(User user, String password) async {
    NetworkHelper networkHelper = NetworkHelper('users/add_user', {
      'device': "mobile",
    });
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{
          'username': user.username,
          'password': password,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'email': user.email,
        }),
        "");

    if (json != null && json['error'] == false) {
      Map u = json['user'];
      User user = User(
        userID: u["id"],
        username: u["username"],
        firstName: u["first_name"],
        lastName: u["last_name"],
        email: u["email"],
      );
      return user;
    }
    return null;
  }
}
