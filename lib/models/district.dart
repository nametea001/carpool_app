import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class District {
  final int? id;
  final int? provinceID;
  final String? nameTH;
  final String? nameEN;

  District({
    this.id,
    this.provinceID,
    this.nameTH,
    this.nameEN,
  });

  static Future<List<District>?> getDistrict(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('districts', {
      'device': "mobile",
    });
    List<District> districts = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['districts']) {
        District district = District(
          id: t['id'],
          provinceID: t['province_id'],
          nameTH: t['name_th'],
          // nameEN: t['name_en'],
        );
        districts.add(district);
      }
      return districts;
    }
    return null;
  }
}