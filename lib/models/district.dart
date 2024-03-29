import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class District {
  int? id;
  int? provinceID;
  String? nameTH;
  String? nameEN;

  District({
    this.id,
    this.provinceID,
    this.nameTH,
    this.nameEN,
  });

  static Future<List<District>?> getDistricts() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('districts', {});
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

  static Future<District?> getDistrictByName(
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('districts/get_by_name', {
      'name': name,
    });
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map d = json['district'];
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

  static Future<District?> getDistrictByProvinceName(
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper =
        NetworkHelper('districts/get_by_province_name', {
      'name': name,
    });
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      Map d = json['district'];
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
}
