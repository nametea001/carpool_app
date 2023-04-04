import 'dart:convert';

import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Province {
  int? id;
  String? nameTH;
  String? nameEN;

  Province({
    this.id,
    this.nameTH,
    this.nameEN,
  });

  static Future<List<Province>?> getProvinces(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('provinces', {});
    List<Province> provinces = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['provinces']) {
        Province province = Province(
          id: t['id'],
          nameTH: t['name_th'],
          nameEN: t['name_en'],
        );
        provinces.add(province);
      }
      return provinces;
    }
    return null;
  }
}
