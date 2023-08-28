import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:car_pool_project/global.dart' as globals;

class NetworkHelper {
  String prefixUrl = globals.serverIP;
  String apiPath = "/api/";
  final String url;
  final Map<String, String> params;

  NetworkHelper(this.url, this.params);

  Future getData(String token) async {
    try {
      http.Response response = await http.get(
        Uri.http(prefixUrl, apiPath + url, params),
        headers: {"Content-Type": "application/json", "auth-token": token},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future postData(String jsonData, token) async {
    try {
      http.Response response = await http
          .post(
            Uri.http(prefixUrl, apiPath + url, params),
            headers: {"Content-Type": "application/json", "auth-token": token},
            body: jsonData,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }

  Future putData(String jsonData, String token) async {
    try {
      http.Response response = await http
          .put(
            Uri.http(prefixUrl, apiPath + url, params),
            headers: {"Content-Type": "application/json", "auth-token": token},
            body: jsonData,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }

  Future deleteData(String token) async {
    try {
      http.Response response = await http.delete(
        Uri.http(prefixUrl, apiPath + url, params),
        headers: {"Content-Type": "application/json", "auth-token": token},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }
}
