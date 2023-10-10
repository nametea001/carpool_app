// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:car_pool_project/global.dart' as globals;

import '../models/chat_detail.dart';

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

  Future<ImageDetails?> getImageDetailsChatDeatil(String myUrl) async {
    Uri uri = Uri.http(prefixUrl, 'chat_details/$myUrl');
    String imageUrl = uri.toString();
    try {
      // Make an HTTP GET request to the image URL
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get the content length from the response headers
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          final sizeInBytes = int.parse(contentLength);
          final sizeInKB = sizeInBytes / 1024; // Convert bytes to kilobytes

          // Create an ImageProvider from the network URL
          ImageProvider imageProvider = NetworkImage(imageUrl);

          // Create an ImageStream and add a listener to it
          final ImageStream imageStream =
              imageProvider.resolve(ImageConfiguration.empty);
          final completer = Completer<ImageDetails>();
          imageStream.addListener(ImageStreamListener(
            (ImageInfo imageInfo, bool synchronousCall) {
              // Get the image width and height from ImageInfo
              final width = imageInfo.image.width;
              final height = imageInfo.image.height;

              // Create an ImageDetails object and complete the completer
              final imageDetails = ImageDetails(
                name: Uri.parse(imageUrl).pathSegments.last,
                sizeInKB: sizeInKB,
                width: width.toDouble(),
                height: height.toDouble(),
                imageUrl: imageUrl,
              );
              completer.complete(imageDetails);
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              // Handle any errors that occur during image loading
              completer.completeError(exception, stackTrace);
            },
          ));

          // Wait for the ImageStream to complete
          return completer.future;
        }
      }

      print('Failed to fetch image: ${response.statusCode}');
      return null;
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error fetching image: $e');
      return null;
    }
  }
}
