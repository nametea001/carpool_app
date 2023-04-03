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

  static Future<List<District>?> getDistricts(
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
          nameEN: t['name_en'],
        );
        districts.add(district);
      }
      return districts;
    }
    return null;
  }

  static Future<District?> getDistrictByNameEN(
    String token,
    String nameEN,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('districts/get_by_name', {
      'device': "mobile",
      'name_en': nameEN,
    });
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map d = json['districts'];
      District district = District(
        id: d['id'],
        provinceID: d['province_id'],
        nameTH: d['name_th'],
        nameEN: d['name_en'],
      );

      return district;
    }
    return null;
  }

  static Future<District?> getDistrictByProvinceNameEN(
    String token,
    String provinceNameEN,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('districts', {
      'device': "mobile",
    });
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map t = json['districts'];
      District district = District(
        id: t['id'],
        provinceID: t['province_id'],
        nameTH: t['name_th'],
        nameEN: t['name_en'],
      );
      return district;
    }
    return null;
  }
}
