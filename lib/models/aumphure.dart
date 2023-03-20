import 'dart:convert';

import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Aumphure {
  final int? id;
  final int? provinceID;
  final String? nameTH;
  final String? nameEN;

  Aumphure({
    this.id,
    this.provinceID,
    this.nameTH,
    this.nameEN,
  });

  static Future<List<Aumphure>?> getAumphure(
    String username,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('aumphures', {
      'device': "mobile",
    });
    List<Aumphure> aumphures = [];
    var json = await networkHelper.getData();
    if (json != null && json['error'] == false) {
      for (Map t in json['aumphures']) {
        Aumphure aumphure = Aumphure(
          id: t['id'],
          provinceID: t['province_id'],
          nameTH: t['name_th'],
          // nameEN: t['name_en'],
        );
        aumphures.add(aumphure);
      }
      return aumphures;
    }
    return null;
  }
}
