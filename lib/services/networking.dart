// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:car_pool_project/global.dart' as globals;
import 'package:path/path.dart';

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

  Future putDataWithImage(
    String token,
    // String jsonData,
    File imageFile,
  ) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest(
          'PUT', Uri.http(prefixUrl, apiPath + url, params));

      // Add headers
      request.headers.addAll({
        "auth-token": token,
      });

      // Add JSON data as a field
      // request.fields['data'] = jsonData;

      // Add the image as a file (let the http package handle the length)
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Send the request
      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // final String data = await response.stream.bytesToString();
        // return jsonDecode(data);
        return true;
      } else {
        // final String data = await response.stream.bytesToString();
        // return jsonDecode(data);
        return false;
      }
    } catch (e) {
      print(e);
    }
  }
}
