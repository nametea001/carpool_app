// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
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

  Future postUpload(String token, File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.http(prefixUrl, apiPath + url, params),
      );
      request.headers['auth-token'] = token;
      var multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);
      var response = await request.send();
      if (response.statusCode == 200) {
        // print('File uploaded successfully');
        String data = await response.stream.bytesToString();
        return jsonDecode(data);
      } else {
        return null;
        // var responseBody = await response.stream.bytesToString();
        // throw Exception('File upload failed: $responseBody');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
