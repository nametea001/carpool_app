import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:car_pool_project/global.dart' as globals;

class NetworkHelper {
  String prefixUrl = '${globals.serverIP}';
  String apiPath = "/api/";
  final String url;
  final Map<String, dynamic> params;
  NetworkHelper(this.url, this.params);

  Future getData() async {
    try {
      http.Response response = await http
          .get(Uri.http(prefixUrl, apiPath + url, params))
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

  Future postData(String jsonData) async {
    try {
      http.Response response = await http
          .post(
            Uri.http(prefixUrl, apiPath + url, params),
            headers: {"Content-Type": "application/json"},
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
}
