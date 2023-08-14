import 'dart:convert';

import 'package:car_pool_project/services/networking.dart';

class User {
  int? id;
  String? username;
  int? userRoleID;
  String? firstName;
  String? lastName;
  String? email;
  String? userRoleName;
  String? img;
  String? jwt;
  String? sex;
  User({
    this.id,
    this.username,
    this.userRoleID,
    this.firstName,
    this.lastName,
    this.email,
    this.userRoleName,
    this.img,
    this.jwt,
    this.sex,
  });

  static Future<User?> checkLoginJWT(String token) async {
    NetworkHelper networkHelper = NetworkHelper('user/checkLoginJWT', {
      'device': "mobile",
    });
    var json = await networkHelper.postData("", token);

    if (json != null && json['error'] == false && json['token'] != null) {
      Map u = json['user'];
      User user = User(
        id: u["id"],
        username: u["username"],
        firstName: u["first_name"],
        lastName: u["last_name"],
        email: u["email"],
        userRoleID: u["user_role_id"],
        userRoleName: u["user_roles"]["user_role_name"],
        img: u['img'],
        jwt: json['token'] ?? "",
      );
      return user;
    }
    return null;
  }

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
        id: u["id"],
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
          'sex': user.sex
        }),
        "");

    if (json != null && json['error'] == false) {
      Map u = json['user'];
      User user = User(
        // id: u["id"],
        username: u["username"],
        // firstName: u["first_name"],
        // lastName: u["last_name"],
        email: u["email"],
        // sex: u["sex"],
      );
      return user;
    }
    return null;
  }
}
