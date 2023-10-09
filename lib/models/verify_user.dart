import 'dart:io';
import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class VerifyUser {
  int? id;
  int? userID;
  String? status;
  String? idCard;
  String? driverLicence;
  String? description;

  VerifyUser({
    this.id,
    this.userID,
    this.status,
    this.idCard,
    this.driverLicence,
    this.description,
  });

  static Future<VerifyUser?> getVerifyUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('verify_users', {});
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['verify_user'];
      VerifyUser userVerify = VerifyUser(
        id: t['id'],
        userID: t['user_id'],
        status: t['status'],
        idCard: t['id_card_path'],
        driverLicence: t['driver_licence_path'],
        description: t['description'],
      );
      return userVerify;
    }
    return null;
  }

  static Future<VerifyUser?> addVerifyUser(String role, File file) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper =
        NetworkHelper('verify_users/upload_file', {"role": role});
    var json = await networkHelper.postUpload(token, file);
    if (json != null && json['error'] == false) {
      Map t = json['verify_user'];
      VerifyUser car = VerifyUser(
        id: t['id'],
        userID: t['user_id'],
        status: t['status'],
        idCard: t['id_card_path'],
        driverLicence: t['driver_licence_path'],
        description: t['description'],
      );
      return car;
    }
    return null;
  }
}
