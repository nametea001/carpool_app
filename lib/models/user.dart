import 'dart:convert';
import 'dart:io';

import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class User {
  int? id;
  String? username;
  int? userRoleID;
  String? firstName;
  String? lastName;
  String? email;
  String? userRoleName;
  String? img;
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
    this.sex,
  });

  static Future<User?> checkLoginJWT(String token) async {
    NetworkHelper networkHelper = NetworkHelper('user/checkLoginJWT', {});
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
        img: u['img_path'],
        sex: u['sex'],
      );
      return user;
    }
    return null;
  }

  static Future<User?> checkLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    NetworkHelper networkHelper = NetworkHelper('login', {});
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
        img: u['img_path'],
        sex: u['sex'],
      );
      await prefs.setString('jwt', json['token']);
      return user;
    }
    return null;
  }

  static Future<User?> signUp(User user, String password) async {
    NetworkHelper networkHelper = NetworkHelper('users/add_user', {});
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

  static Future<dynamic> getUserForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('', {});
    var json = await networkHelper.getData(token);

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
        img: u['img_path'],
        sex: u['sex'],
      );
      return [user, json['token']];
    }
    return null;
  }

  static Future<User?> editProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('users/edit_profile', {});
    var json = await networkHelper.putData(
        jsonEncode(<String, dynamic>{
          'first_name': user.firstName,
          'last_name': user.lastName,
          'email': user.email,
          'sex': user.sex
        }),
        token);
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
        img: u['img_path'],
        sex: u['sex'],
      );
      await prefs.setString('jwt', json['token']);
      return user;
    }
    return null;
  }

  static Future<String?> uploadProfileImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('users/upload_image', {});
    var json = await networkHelper.postUpload(token, imageFile);
    if (json != null && json['error'] == false) {
      return json['img_path'];
    }
    return null;
  }
}
